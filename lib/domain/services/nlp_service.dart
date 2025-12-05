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
    required MonthlySummary summary,
    required GoalsState goals,
    required Profile profile,
  }) async {
    // 1. Check if API key is present
    if (AppConstants.geminiApiKey.isEmpty) {
       return const AiInsight(message: "AI configuration is missing (API Key). Please contact the developer.");
    }

    // 2. Build Context Prompt
    final prompt = _buildPrompt(question, summary, goals, profile);

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

  String _buildPrompt(String question, MonthlySummary summary, GoalsState goals, Profile profile) {
    final name = profile.name ?? 'Advisor';
    return '''
    You are an intelligent assistant for "Advisor Desk", a performance tracking app for customer care advisors.
    Your name is "Advisor Assistant". You are helpful, motivating, and professional.
    
    User Context:
    - Name: $name
    - Month: ${summary.formattedMonthYear}
    - Company: ${profile.companyName ?? 'N/A'}
    
    Current Performance Data:
    - Total Calls: ${summary.totalCalls}
    - Total Login Hours: ${summary.totalLoginHours.toStringAsFixed(2)} hours
    - Goal Target Calls: ${goals.targetCalls}
    - Goal Target Hours: ${goals.targetHours}
    - CSAT Score: ${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%
    - CQ Score: ${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%
    - Net Salary Projected: ₹${summary.netSalary.toStringAsFixed(2)}
    - Bonus Achieved: ${summary.isBonusAchieved ? 'Yes' : 'No'}
    
    User Question: "$question"
    
    Instructions:
    - Answer the user's question directly based on the provided data.
    - Be concise and friendly.
    - If the user asks for a comparison but you don't have previous month data here, gently explain you are looking at the current month.
    - Do not invent data not shown above.
    - If the question is unrelated to work/performance, politely guide them back to the app's purpose.
    ''';
  }
}
