import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/query_parser.dart'; // Keeping for now if we want hybrid, but mostly replacing
// import 'package:advisor_desk/domain/services/query_models.dart'; // Might remove if unused
import 'package:google_generative_ai/google_generative_ai.dart';

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
    required List<MonthlySummary> histories, // Changed from single summary to list
    required GoalsState goals,
    required Profile profile,
  }) async {
    // 1. Check if API key is present
    if (AppConstants.geminiApiKey.isEmpty) {
       return const AiInsight(message: "AI configuration is missing (API Key). Please contact the developer.");
    }

    // 2. Build Context Prompt
    final prompt = _buildPrompt(question, histories, goals, profile);

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

  String _buildPrompt(String question, List<MonthlySummary> histories, GoalsState goals, Profile profile) {
    final name = profile.name ?? 'Advisor';
    
    // Sort histories by date (newest first) usually better for context, but chronological for reading. 
    // Let's do reverse chronological (newest at top of list provided, but in text maybe list them clearly).
    
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
        dataBuffer.writeln("---"); // Separator
      }
    }

    return '''
    You are an intelligent assistant for "Advisor Desk", a performance tracking app for customer care advisors.
    Your name is "Advisor Assistant". You are helpful, motivating, professional, and conversational.
    
    User Context:
    - Name: $name
    - Company: ${profile.companyName ?? 'N/A'}
    
    Current Goals:
    - Target Calls: ${goals.targetCalls}
    - Target Hours: ${goals.targetHours}
    
    Available Performance Data (Last 12 Months):
    $dataBuffer
    
    User Question: "$question"
    
    Instructions:
    1. **Direct Answers**: Answer the user's question directly based on the "Available Performance Data" provided above.
    2. **Handling Ambiguity**: 
       - If the user asks about a specific month (e.g., "November") and the data contains multiple Novembers (e.g., Nov 2023 and Nov 2024), **DO NOT GUESS**. Instead, ask the user to clarify: "Did you mean November 2023 or November 2024?".
       - If the user asks for a month for which there is NO data in the list above, state clearly: "I don't have data for [Month] yet. Please add some entries for that month."
    3. **Tone**: Be concise, friendly, and act like a human assistant. Use emojis occasionally if appropriate.
    4. **Complex Queries**: If the user asks for comparisons (e.g., "Compare Oct and Nov"), use the data to provide a clear comparison of Calls, Login Hours, and Scores.
    5. **Privacy**: Do not invent data. If it's not in the list, you don't know it.
    ''';
  }
}
