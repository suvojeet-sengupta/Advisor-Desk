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
    
    // Sort histories by date
    final StringBuffer dataBuffer = StringBuffer();
    if (histories.isEmpty) {
      dataBuffer.writeln("No historical data available.");
    } else {
      for (final summary in histories) {
        dataBuffer.writeln("Month: ${summary.formattedMonthYear}");
        dataBuffer.writeln("- Total Calls: ${summary.totalCalls}");
        dataBuffer.writeln("- Total Login Hours: ${summary.totalLoginHours.toStringAsFixed(2)}");
        dataBuffer.writeln("- CSAT Score: ${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%");
        dataBuffer.writeln("- CQ Score: ${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%");
        dataBuffer.writeln("- Net Salary: ₹${summary.netSalary.toStringAsFixed(2)}");
        dataBuffer.writeln("- Bonus: ${summary.isBonusAchieved ? 'Yes' : 'No'}");
        dataBuffer.writeln("---"); 
      }
    }

    // Specific Daily Data Context
    final StringBuffer dailyDataBuffer = StringBuffer();
    if (dailyEntry != null) {
      dailyDataBuffer.writeln("Detailed Data for Requested Date (${dailyEntry.date.toLocal().toString().split(' ')[0]}):");
      dailyDataBuffer.writeln("- Calls: ${dailyEntry.callCount}");
      dailyDataBuffer.writeln("- Login Time: ${dailyEntry.formattedLoginTime}");
      dailyDataBuffer.writeln("- Login Hours (Decimal): ${dailyEntry.totalLoginTimeInHours.toStringAsFixed(2)}");
    } else if (requestedDate != null) {
       dailyDataBuffer.writeln("User requested data for date: ${requestedDate.toLocal().toString().split(' ')[0]}, but NO ENTRY was found in the database for this date.");
    }

    // Format recent chat history (last 5 messages for context)
    final StringBuffer historyBuffer = StringBuffer();
    final recentHistory = chatHistory.length > 5 ? chatHistory.sublist(chatHistory.length - 5) : chatHistory;
    for (final insight in recentHistory) {
      final role = insight.isUser ? "User" : "Advisor Assistant";
      historyBuffer.writeln("$role: ${insight.message}");
    }

    return '''
    You are an intelligent assistant for "Advisor Desk".
    Your name is "Advisor Assistant". 
    
    **Current Context**:
    - User Name: $name
    - Company: ${profile.companyName ?? 'N/A'}
    - Current Time: $timeString
    - Goals: Calls ${goals.targetCalls}, Hours ${goals.targetHours}
    
    **Performance Data (Last 12 Months)**:
    $dataBuffer
    
    **Specific Daily Data (If requested)**:
    ${dailyDataBuffer.isEmpty ? "No specific date requested." : dailyDataBuffer.toString()}
    
    **Recent Conversation**:
    $historyBuffer
    User: "$question"
    
    **Instructions**:
    1. **Persona**: Act strictly as a human colleague/friend. Be casual, empathetic, and natural. Do NOT be robotic or overly formal.
       - Use comments like "late night?", "good morning!", "long day?" based on the Current Time.
    2. **Language Matching**: Reply in the EXACT SAME language and script as the user. 
       - If User speaks English -> Reply in English.
       - If User speaks Hindi -> Reply in Hindi (Devanagari).
       - If User speaks Hinglish (Hindi in English script) -> Reply in Hinglish.
       - If User mixes -> Mix naturally.
    3. **Conciseness**: Keep answers short, crisp, and to the point. No long paragraphs unless necessary for complex explanations.
    4. **Context**: Use the "Recent Conversation" to understand follow-up questions.
    5. **Data**: Answer strictly based on "Performance Data" or "Specific Daily Data" if present. 
       - If "Specific Daily Data" says NO ENTRY was found, explicitly tell the user: "I checked, but you haven't added any data for that date yet."
       - If asking for month X and data has multiple years, ask for clarification.
    6. **Hypotheticals**: If the user asks "What if..." questions regarding work (e.g., "What if I miss 3 days login?", "What if I do 100 calls less?"), use the provided data and goals to ESTIMATE the impact. Be helpful but clarify these are estimates.
    7. **Relevance**: 
       - If the question is about general knowledge (e.g., "What is LLM?", "Meaning of life", "Who is PM"), general definitions, or topics unrelated to work performance/goals, **SMARTLY IGNORE** it.
       - Deflect casually: "Arre yaar, I focus on your performance stats!" or "Let's stick to your goals, buddy." or "I'm your work assistant, not Google!" 
       - Do NOT answer the irrelevant question.
    
    Response:
    ''';
  }
}
