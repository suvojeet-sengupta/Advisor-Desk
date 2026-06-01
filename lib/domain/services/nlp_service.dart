import 'dart:convert';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/ai_response.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/query_parser.dart';
import 'package:advisor_desk/domain/services/advisor_ai_tools.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

class NlpService {
  final PerformanceRepository _performanceRepository;
  final QueryParser _queryParser;
  late final GenerativeModel _modelPrimary;   // gemini-3-flash
  late final GenerativeModel _modelFallback1; // gemini-2.5-flash
  late final GenerativeModel _modelFallback2; // gemini-2.5-flash-lite
  late final AdvisorAiTools _tools;

  NlpService({required PerformanceRepository performanceRepository, required QueryParser queryParser})
      : _performanceRepository = performanceRepository,
        _queryParser = queryParser {
          _modelPrimary = GenerativeModel(
            model: 'gemini-3-flash-preview',
            apiKey: AppConstants.geminiApiKey,
          );
          _modelFallback1 = GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: AppConstants.geminiApiKey,
          );
          _modelFallback2 = GenerativeModel(
            model: 'gemini-2.5-flash-lite',
            apiKey: AppConstants.geminiApiKey,
          );
          _tools = AdvisorAiTools(_performanceRepository);
        }

  // Duration for showing "Switching model..." indicator
  static const Duration modelSwitchDisplayDuration = Duration(seconds: 3);

  // Check if error indicates quota/limit exceeded and should trigger fallback
  bool _shouldUseFallbackModel(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('quota') || 
           errorMessage.contains('limit') || 
           errorMessage.contains('resource') ||
           errorMessage.contains('exceeded') ||
           errorMessage.contains('429');
  }

  Future<AiResponse> processQuestion({
    required String question,
    required List<MonthlySummary> histories,
    required GoalsState goals,
    required Profile profile,
    required List<AiInsight> chatHistory,
    DailyEntry? dailyEntry,
    DateTime? requestedDate,
  }) async {
    if (AppConstants.geminiApiKey.isEmpty) {
       return AiResponse(
         insight: AiInsight(message: "AI configuration is missing (API Key). Please contact the developer."),
         modelSwitched: false,
       );
    }

    final prompt = _buildPrompt(question, histories, goals, profile, chatHistory, dailyEntry, requestedDate);

    // Try Primary: gemini-3-flash
    try {
      final response = await _generateWithTools(_modelPrimary, prompt);
      return _handleResponse(response, false);
    } catch (e) {
      if (_shouldUseFallbackModel(e)) {
        // Try Fallback 1: gemini-2.5-flash
        try {
          final response = await _generateWithTools(_modelFallback1, prompt);
          return _handleResponse(response, true);
        } catch (e2) {
          if (_shouldUseFallbackModel(e2)) {
            // Try Fallback 2: gemini-2.5-flash-lite
            try {
              final response = await _generateWithTools(_modelFallback2, prompt);
              return _handleResponse(response, true);
            } catch (e3) {
              return AiResponse(
                insight: AiInsight(message: "All AI models are currently busy or reached their limit: $e3"),
                modelSwitched: true,
              );
            }
          }
          return AiResponse(
            insight: AiInsight(message: "Error connecting to AI brain: $e2"),
            modelSwitched: true,
          );
        }
      }
      return AiResponse(
        insight: AiInsight(message: "I encountered an error connecting to my brain: $e"),
        modelSwitched: false,
      );
    }
  }

  /// Runs a single model through the tool-calling loop.
  ///
  /// The model is given the tool schemas and asked the question. When it
  /// requests tool calls, we execute them against the local repository and feed
  /// the results back **as plain text** (not as `functionResponse` parts).
  ///
  /// Why text instead of native function-response parts: Gemini 3 / 2.5
  /// (thinking) models attach a `thought_signature` to each `functionCall`, and
  /// the API rejects the follow-up request unless that signature is round-tripped.
  /// The legacy `google_generative_ai` package doesn't expose/preserve the
  /// signature, so resubmitting the `functionCall` part fails with a
  /// "missing thought_signature" error. By never resubmitting `functionCall`
  /// parts and instead passing results as natural-language text, the signature
  /// requirement does not apply — and we can keep using gemini-3.
  Future<GenerateContentResponse> _generateWithTools(
      GenerativeModel model, String basePrompt) async {
    final content = <Content>[Content.text(basePrompt)];

    var response =
        await model.generateContent(content, tools: AdvisorAiTools.tools);

    var guard = 0;
    const maxRounds = 3;
    while (response.functionCalls.isNotEmpty && guard < maxRounds) {
      guard++;

      final buffer = StringBuffer(
          'TOOL RESULTS (use these to answer the question; do NOT call the same '
          'tool again with the same arguments):\n');
      for (final call in response.functionCalls) {
        final result = await _tools.executeTool(call.name, call.args);
        buffer.writeln('- ${call.name}(${jsonEncode(call.args)}) => '
            '${jsonEncode(result)}');
      }
      content.add(Content.text(buffer.toString()));

      // On the final allowed round, drop the tools so the model is forced to
      // produce a textual answer instead of requesting yet more data.
      final toolsForNext = guard >= maxRounds ? null : AdvisorAiTools.tools;
      response = await model.generateContent(content, tools: toolsForNext);
    }

    return response;
  }

  AiResponse _handleResponse(GenerateContentResponse response, bool switched) {
    final text = response.text;
    if (text == null || text.isEmpty) {
      return AiResponse(
        insight: AiInsight(message: "I'm having trouble thinking right now. Please try again."),
        modelSwitched: switched,
      );
    }
    return AiResponse(
      insight: AiInsight(message: text),
      modelSwitched: switched,
    );
  }

  String _buildPrompt(String question, List<MonthlySummary> histories, GoalsState goals, Profile profile, List<AiInsight> chatHistory, DailyEntry? dailyEntry, DateTime? requestedDate) {
    final name = profile.name ?? 'Advisor';
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeString = "$dateStr ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Build a COMPACT monthly index (overview only). Detailed numbers — daily
    // entries, CSAT/CQ breakdowns, full salary breakdown — are fetched on demand
    // by the model via tools (see DATA TOOLS instructions below). This keeps the
    // prompt small instead of dumping the entire history every time.
    final StringBuffer dataBuffer = StringBuffer();
    if (histories.isEmpty) {
      dataBuffer.writeln("No historical data available.");
    } else {
      for (final summary in histories) {
        final csat = summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(1) ?? 'N/A';
        final cq = summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(1) ?? 'N/A';
        dataBuffer.writeln(
          "- ${summary.formattedMonthYear} (month=${summary.month}, year=${summary.year}): "
          "Calls=${summary.totalCalls}, Hours=${summary.totalLoginHours.toStringAsFixed(1)}, "
          "Days=${summary.entries.length}, CSAT=$csat%, CQ=$cq%, Net=₹${summary.netSalary.toStringAsFixed(0)}",
        );
      }
    }

    // Specific Daily Data Context
    final StringBuffer dailyDataBuffer = StringBuffer();
    if (dailyEntry != null) {
      dailyDataBuffer.writeln("SPECIFIC DATE DATA (${dailyEntry.date.day}/${dailyEntry.date.month}/${dailyEntry.date.year}):");
      dailyDataBuffer.writeln("- Calls: ${dailyEntry.callCount}");
      dailyDataBuffer.writeln("- Login Time: ${dailyEntry.formattedLoginTime}");
      dailyDataBuffer.writeln("- Login Hours (Decimal): ${dailyEntry.totalLoginTimeInHours.toStringAsFixed(2)}");
      if (dailyEntry.customCallRate != null) {
        dailyDataBuffer.writeln("- Custom Per Call Rate: ₹${dailyEntry.customCallRate}");
      }
    } else if (requestedDate != null) {
       dailyDataBuffer.writeln("User requested data for ${requestedDate.day}/${requestedDate.month}/${requestedDate.year}, but NO ENTRY was found.");
    }

    // Format recent chat history (last 6 messages for context)
    final StringBuffer historyBuffer = StringBuffer();
    final recentHistory = chatHistory.length > 6 ? chatHistory.sublist(chatHistory.length - 6) : chatHistory;
    bool questionAlreadyInHistory = false;
    
    if (recentHistory.isNotEmpty) {
      final lastInsight = recentHistory.last;
      if (lastInsight.isUser && lastInsight.message.trim() == question.trim()) {
        questionAlreadyInHistory = true;
      }
    }

    for (final insight in recentHistory) {
      final role = insight.isUser ? "User" : "Assistant";
      historyBuffer.writeln("$role: ${insight.message}");
    }

    return '''
You are "Advisor Assistant", an intelligent AI for "Advisor Desk" app that tracks call center advisor performance.

**SYSTEM INSTRUCTIONS**:
1. You are a helpful assistant.
2. **DO NOT** repeat your greeting (e.g., "Hello Suvojeet! I'm ready to help...") if you see that you have already greeted the user in the **RECENT CONVERSATION** history.
3. If the user asks a question, answer it DIRECTLY.

**DATA TOOLS (IMPORTANT)**:
- Tumhare paas ye tools hain: `list_recent_months`, `get_monthly_summary`,
  `get_entries_for_month`, `get_daily_entry`, `get_csat_summary`, `get_cq_summary`.
- Neeche sirf ek COMPACT MONTHLY OVERVIEW diya hai. Jab bhi detailed numbers chahiye
  (kisi specific din ke calls, CSAT/CQ ka day-wise breakdown, full salary breakdown,
  ya kisi month ke saare daily entries) to relevant TOOL call karo — numbers GUESS mat karo.
- Dates ke liye `get_daily_entry` ko ISO format (YYYY-MM-DD) mein date do. Current year
  ka pata Current Time se lagao.

**CURRENT CONTEXT**:
- User Name: $name
- Company: ${profile.companyName ?? 'N/A'}
- Current Time: $timeString
- Monthly Goals: ${goals.targetCalls} calls, ${goals.targetHours} hours

**MONTHLY OVERVIEW (compact — use tools for details)**:
$dataBuffer

**SPECIFIC DATE DATA (If requested)**:
${dailyDataBuffer.isEmpty ? "No specific date requested." : dailyDataBuffer.toString()}

**RECENT CONVERSATION**:
$historyBuffer

**CURRENT USER QUESTION**:
${questionAlreadyInHistory ? '(See last message above)' : '"$question"'}

**TASK**:
Answer the **CURRENT USER QUESTION** based on the data provided. Do not ignore the question.

**RESPONSE STYLE**:
1. **DIRECT ANSWERS**: Answer exactly what user asked. No fluff.
   - "5 December ko kitne calls?" → "**5 December** ko **150 calls** kiye."

2. **FORMATTING**:
   - Use **bold** for numbers, dates, key metrics
   - Use bullet points for lists
   - Keep paragraphs short (2-3 lines)

3. **LANGUAGE**: Match user's language (English/Hindi/Hinglish)

4. **WHAT-IF SCENARIOS**: For questions like "Agar 5 din login na karu to?" do FULL ANALYSIS:

   **Step 1: Current Status**
   - Current month ka total calls & hours
   - Goal calls & hours
   - Days already worked
   - Days remaining in month
   
   **Step 2: Calculate Impact**
   - New remaining days = remaining days - missed days
   - Remaining calls to goal = goal - current calls
   - Remaining hours to goal = goal - current hours
   - New daily avg calls needed = remaining calls / new remaining days
   - New daily avg hours needed = remaining hours / new remaining days
   
   **Step 3: Prediction**
   - Current daily avg calls (from data)
   - Current daily avg hours (from data)
   - Compare required vs current avg
   - Will goal be achievable? Yes/No with numbers
   
   **Step 4: Clear Conclusion**
   - "Agar 5 din miss kiye to:"
   - "Daily **X calls** karne honge (vs current avg **Y**)"
   - "Daily **X hours** login hona hoga (vs current avg **Y**)"
   - "Target miss hone ka risk: High/Medium/Low"
   
   **Example Response for "Agar 5 din login nahi karu?":**
   "**Current Status (December 2025):**
   - Calls: **1100/3000** (1900 remaining)
   - Hours: **45/150** (105 remaining)
   - Days worked: **6**, Days left: **25**
   
   **Agar 5 din miss karo:**
   - New remaining days: **20**
   - Daily calls needed: **95/day** (current avg: **183**)
   - Daily hours needed: **5.25 hrs/day** (current avg: **7.5**)
   
   **Verdict:** Achievable hai, but daily calls kam ho jayega. Tumhara current pace bahut acha hai, 5 din miss karne se bhi goal mil jayega! 👍"

5. **PREDICTIONS**: When asked about trends:
   - Calculate daily average from data
   - Project to end of month
   - Compare with goals
   - Give clear "On track" or "Behind" verdict

6. **IF DATA MISSING**: "Is date/month ka data available nahi hai."

7. **CREATOR**: If asked "Who made you?" → "Suvojeet Sengupta"

8. **OFF-TOPIC**: "Yaar, main sirf tumhari performance stats dekh sakta hoon!"

Response:
''';
  }

  Future<AiInsight> suggestGoals({
    required List<MonthlySummary> histories,
    required Profile profile,
  }) async {
    if (AppConstants.geminiApiKey.isEmpty) {
      return AiInsight(message: "Error: AI not configured.");
    }

    // 1. Build Prompt
    final StringBuffer dataBuffer = StringBuffer();
    // Sort slightly to be safe
    final sortedHistories = List<MonthlySummary>.from(histories)
      ..sort((a, b) => a.year == b.year ? a.month.compareTo(b.month) : a.year.compareTo(b.year));
    
    // Take last 6 months for relevance
    final relevantHistory = sortedHistories.length > 6 ? sortedHistories.sublist(sortedHistories.length - 6) : sortedHistories;

    for (final summary in relevantHistory) {
      dataBuffer.writeln("Month: ${summary.formattedMonthYear}, Calls: ${summary.totalCalls}, Hours: ${summary.totalLoginHours.round()}");
    }

    final prompt = '''
    You are a data analyst for a work performance app.
    
    **User History (Last 6 Months)**:
    $dataBuffer

    **Task**:
    Suggest realistic but challenging goals for the NEXT month based on the trend.
    - If trend is up, increase slightly (5-10%).
    - If trend is stable, maintain or slight push.
    - If irregular, suggest an average.

    **Output Format**:
    Return ONLY a JSON string. No markdown, no explanations.
    {
      "suggestedCalls": <int>,
      "suggestedHours": <int>,
      "reasoning": "<short single sentence reasoning>"
    }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _modelPrimary.generateContent(content);
      return AiInsight(message: response.text ?? "");
    } catch (e) {
      if (_shouldUseFallbackModel(e)) {
        try {
          final response = await _modelFallback1.generateContent([Content.text(prompt)]);
          return AiInsight(message: response.text ?? "");
        } catch (e2) {
          if (_shouldUseFallbackModel(e2)) {
            try {
              final response = await _modelFallback2.generateContent([Content.text(prompt)]);
              return AiInsight(message: response.text ?? "");
            } catch (e3) {
              return AiInsight(message: "Error generating goals: $e3");
            }
          }
          return AiInsight(message: "Error generating goals: $e2");
        }
      }
      return AiInsight(message: "Error generating goals: $e");
    }
  }
}