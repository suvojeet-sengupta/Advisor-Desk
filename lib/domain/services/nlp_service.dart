import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/query_parser.dart'; // Keeping for now if we want hybrid, but mostly replacing
// import 'package:advisor_desk/domain/services/query_models.dart'; // Might remove if unused
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

class NlpService {
  final PerformanceRepository _performanceRepository;
  final QueryParser _queryParser; // Keeping dependency to avoid breaking DI immediately, but can be unused.
  late final GenerativeModel _modelLite;
  late final GenerativeModel _modelFlash;

  NlpService({required PerformanceRepository performanceRepository, required QueryParser queryParser})
      : _performanceRepository = performanceRepository,
        _queryParser = queryParser {
          _modelLite = GenerativeModel(
            model: 'gemini-2.5-flash-lite', 
            apiKey: AppConstants.geminiApiKey,
          );
          _modelFlash = GenerativeModel(
            model: 'gemini-2.5-flash', 
            apiKey: AppConstants.geminiApiKey,
          );
        }

  Future<Map<String, dynamic>> processQuestion({
    required String question,
    required List<MonthlySummary> histories,
    required GoalsState goals,
    required Profile profile,
    required List<AiInsight> chatHistory, // Add chat history
    DailyEntry? dailyEntry,
    DateTime? requestedDate,
  }) async {
    // 1. Check if API key is present
    if (AppConstants.geminiApiKey.isEmpty) {
       return {
         'insight': const AiInsight(message: "AI configuration is missing (API Key). Please contact the developer."),
         'modelSwitched': false,
       };
    }

    // 2. Build Context Prompt
    final prompt = _buildPrompt(question, histories, goals, profile, chatHistory, dailyEntry, requestedDate);

    try {
      // 3. Generate Content with gemini-2.5-flash-lite
      final content = [Content.text(prompt)];
      final response = await _modelLite.generateContent(content);

      final text = response.text;
      if (text == null || text.isEmpty) {
        return {
          'insight': const AiInsight(message: "I'm having trouble thinking right now. Please try again."),
          'modelSwitched': false,
        };
      }

      return {
        'insight': AiInsight(message: text),
        'modelSwitched': false,
      };

    } catch (e) {
      // Check if error is quota/limit exceeded
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('quota') || 
          errorMessage.contains('limit') || 
          errorMessage.contains('resource') ||
          errorMessage.contains('exceeded')) {
        
        // Try fallback to gemini-2.5-flash
        try {
          final content = [Content.text(prompt)];
          final response = await _modelFlash.generateContent(content);

          final text = response.text;
          if (text == null || text.isEmpty) {
            return {
              'insight': const AiInsight(message: "I'm having trouble thinking right now. Please try again."),
              'modelSwitched': true,
            };
          }

          return {
            'insight': AiInsight(message: text),
            'modelSwitched': true,
          };
        } catch (fallbackError) {
          return {
            'insight': AiInsight(message: "I encountered an error connecting to my brain: $fallbackError"),
            'modelSwitched': true,
          };
        }
      }
      
      return {
        'insight': AiInsight(message: "I encountered an error connecting to my brain: $e"),
        'modelSwitched': false,
      };
    }
  }

  String _buildPrompt(String question, List<MonthlySummary> histories, GoalsState goals, Profile profile, List<AiInsight> chatHistory, DailyEntry? dailyEntry, DateTime? requestedDate) {
    final name = profile.name ?? 'Advisor';
    final now = DateTime.now();
    final timeString = "${now.hour}:${now.minute}";
    
    // Build comprehensive data context
    final StringBuffer dataBuffer = StringBuffer();
    if (histories.isEmpty) {
      dataBuffer.writeln("No historical data available.");
    } else {
      for (final summary in histories) {
        dataBuffer.writeln("=== ${summary.formattedMonthYear} ===");
        dataBuffer.writeln("SUMMARY:");
        dataBuffer.writeln("- Total Calls: ${summary.totalCalls}");
        dataBuffer.writeln("- Billable Calls: ${summary.billableCalls}");
        dataBuffer.writeln("- Non-Billable Calls: ${summary.totalNonBillableCalls}");
        dataBuffer.writeln("- Total Login Hours: ${summary.totalLoginHours.toStringAsFixed(2)}");
        dataBuffer.writeln("- Working Days: ${summary.entries.length}");
        dataBuffer.writeln("- Avg Calls/Day: ${summary.averageDailyCalls.toStringAsFixed(1)}");
        dataBuffer.writeln("- Avg Hours/Day: ${summary.averageDailyLoginHours.toStringAsFixed(2)}");
        dataBuffer.writeln("- CSAT Score: ${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%");
        dataBuffer.writeln("- CQ Score: ${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%");
        dataBuffer.writeln("SALARY BREAKDOWN:");
        dataBuffer.writeln("- Base Salary: ₹${summary.baseSalary.toStringAsFixed(2)}");
        dataBuffer.writeln("- Performance Bonus: ₹${summary.bonusAmount.toStringAsFixed(2)} (${summary.isBonusAchieved ? 'Achieved' : 'Not Achieved'})");
        dataBuffer.writeln("- CSAT Bonus: ₹${summary.csatBonus.toStringAsFixed(2)}");
        dataBuffer.writeln("- Gross Salary: ₹${(summary.totalSalary + summary.csatBonus).toStringAsFixed(2)}");
        dataBuffer.writeln("- TDS Deduction: ₹${summary.tdsDeduction.toStringAsFixed(2)}");
        dataBuffer.writeln("- Net Salary: ₹${summary.netSalary.toStringAsFixed(2)}");
        
        // Daily Entries Detail
        if (summary.entries.isNotEmpty) {
          dataBuffer.writeln("\nDAILY ENTRIES (${summary.entries.length} days):");
          for (final entry in summary.entries) {
            final dateStr = "${entry.date.day}/${entry.date.month}/${entry.date.year}";
            dataBuffer.writeln("  $dateStr: Calls=${entry.callCount}, Hours=${entry.formattedLoginTime}${entry.customCallRate != null ? ', CustomRate=₹${entry.customCallRate}' : ''}");
          }
        }
        
        // CSAT Entries Detail
        if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) {
          dataBuffer.writeln("\nCSAT ENTRIES (${summary.csatSummary!.entries.length} days):");
          dataBuffer.writeln("  Monthly: T2=${summary.csatSummary!.totalT2Count}, B2=${summary.csatSummary!.totalB2Count}, N=${summary.csatSummary!.totalNCount}, Hits=${summary.csatSummary!.totalSurveyHits}");
          for (final csatEntry in summary.csatSummary!.entries) {
            final dateStr = "${csatEntry.date.day}/${csatEntry.date.month}/${csatEntry.date.year}";
            dataBuffer.writeln("  $dateStr: T2=${csatEntry.t2Count}, B2=${csatEntry.b2Count}, N=${csatEntry.nCount}, CSAT=${csatEntry.csatPercentage.toStringAsFixed(1)}%");
          }
        }
        
        // CQ Entries Detail
        if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) {
          dataBuffer.writeln("\nCQ ENTRIES (${summary.cqSummary!.entries.length} audits):");
          dataBuffer.writeln("  Monthly Avg: ${summary.cqSummary!.monthlyAverageCQ.toStringAsFixed(2)}%, Rating: ${summary.cqSummary!.qualityRating}");
          for (final cqEntry in summary.cqSummary!.entries) {
            final dateStr = "${cqEntry.auditDate.day}/${cqEntry.auditDate.month}/${cqEntry.auditDate.year}";
            dataBuffer.writeln("  $dateStr: Score=${cqEntry.percentage.toStringAsFixed(1)}%");
          }
        }
        
        dataBuffer.writeln(""); // Empty line between months
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
    for (final insight in recentHistory) {
      final role = insight.isUser ? "User" : "Assistant";
      historyBuffer.writeln("$role: ${insight.message}");
    }

    return '''
You are "Advisor Assistant", an intelligent AI for "Advisor Desk" app that tracks call center advisor performance.

**CURRENT CONTEXT**:
- User Name: $name
- Company: ${profile.companyName ?? 'N/A'}
- Current Time: $timeString
- Monthly Goals: ${goals.targetCalls} calls, ${goals.targetHours} hours

**COMPREHENSIVE PERFORMANCE DATA**:
$dataBuffer

**SPECIFIC DATE DATA (If requested)**:
${dailyDataBuffer.isEmpty ? "No specific date requested." : dailyDataBuffer.toString()}

**RECENT CONVERSATION**:
$historyBuffer
User: "$question"

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
      return const AiInsight(message: "Error: AI not configured.");
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
      final response = await _modelLite.generateContent(content);
      return AiInsight(message: response.text ?? "");
    } catch (e) {
      return AiInsight(message: "Error generating goals: $e");
    }
  }
}
