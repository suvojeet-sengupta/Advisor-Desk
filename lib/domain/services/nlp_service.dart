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
  late final GenerativeModel _model;

  NlpService({required PerformanceRepository performanceRepository, required QueryParser queryParser})
      : _performanceRepository = performanceRepository,
        _queryParser = queryParser {
          _model = GenerativeModel(
            model: 'gemini-2.5-flash-lite', 
            apiKey: AppConstants.geminiApiKey,
          );
        }

  Future<AiInsight> processQuestion({
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
       return const AiInsight(message: "AI configuration is missing (API Key). Please contact the developer.");
    }

    // 2. Build Context Prompt
    final prompt = _buildPrompt(question, histories, goals, profile, chatHistory, dailyEntry, requestedDate);

    try {
      // 3. Generate Content
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final text = response.text;
      if (text == null || text.isEmpty) {
        return const AiInsight(message: "I'm having trouble thinking right now. Please try again.");
      }

      return AiInsight(message: text);

    } catch (e) {
      return AiInsight(message: "I encountered an error connecting to my brain: $e");
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
1. **DIRECT ANSWERS**: Answer exactly what user asked. No extra fluff or beating around the bush.
   - If user asks "Kitne calls kiye 5 December ko?" → Answer: "5 December ko tumne 150 calls kiye."
   - Don't add unnecessary context unless asked.

2. **EXPLAIN WHEN NEEDED**: If question needs explanation, explain clearly:
   - Use bullet points for multiple items
   - Use **bold** for important numbers/dates
   - Break complex answers into sections

3. **FORMATTING**:
   - Use **bold** for dates, numbers, and key metrics
   - Use bullet points (- or *) for lists
   - Use line breaks between sections for readability
   - Keep paragraphs short (2-3 lines max)

4. **LANGUAGE**: Match user's language exactly (English/Hindi/Hinglish)

5. **EXAMPLES**:
   - Question: "Meri CSAT kya hai?" → "Tumhari **December 2025** ki CSAT **72.5%** hai. Total **45 T2**, **12 B2** aur **8 N** mile."
   - Question: "Compare October November" → 
     "**October vs November:**
     - Calls: **548** → **334** (214 kam)
     - CSAT: **65%** → **72%** (7% better)
     - CQ: **85%** → **88%** (3% up)"

6. **IF DATA MISSING**: Simply say "Is date/month ka data available nahi hai."

7. **CREATOR**: If asked "Who made you?" → "Suvojeet Sengupta"

8. **OFF-TOPIC**: Politely redirect: "Yaar, main sirf tumhari performance stats dekh sakta hoon!"

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
      final response = await _model.generateContent(content);
      return AiInsight(message: response.text ?? "");
    } catch (e) {
      return AiInsight(message: "Error generating goals: $e");
    }
  }
}
