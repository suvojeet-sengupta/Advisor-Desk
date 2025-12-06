import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';

abstract class GoalPredictionService {
  Future<Map<String, int>> suggestGoals(List<MonthlySummary> historicalSummaries);
  Future<Map<String, int>> suggestGoalsWithAI(List<MonthlySummary> historicalSummaries, Profile profile);
}

class GoalPredictionServiceImpl implements GoalPredictionService {
  final NlpService _nlpService;

  GoalPredictionServiceImpl({required NlpService nlpService}) : _nlpService = nlpService;

  @override
  Future<Map<String, int>> suggestGoals(List<MonthlySummary> historicalSummaries) async {
    if (historicalSummaries.isEmpty) {
      return {'hours': 0, 'calls': 0};
    }

    // Sort summaries by date to ensure correct chronological order
    historicalSummaries.sort((a, b) => a.year == b.year ? a.month.compareTo(b.month) : a.year.compareTo(b.year));

    // Use all available summaries for a more robust trend analysis
    final List<double> hoursData = historicalSummaries.map((s) => s.totalLoginHours).toList();
    final List<int> callsData = historicalSummaries.map((s) => s.totalCalls).toList();

    double calculateAverageGrowth(List<num> data) {
      if (data.length < 2) return 1.05; // Default 5% growth if not enough data

      double totalGrowth = 0;
      int count = 0;
      for (int i = 1; i < data.length; i++) {
        if (data[i - 1] > 0) {
          totalGrowth += (data[i] / data[i - 1]);
          count++;
        }
      }
      return count > 0 ? totalGrowth / count : 1.05; // Default 5% growth
    }

    final double avgHoursGrowthFactor = calculateAverageGrowth(hoursData);
    final double avgCallsGrowthFactor = calculateAverageGrowth(callsData);

    final MonthlySummary latestSummary = historicalSummaries.last;

    // Project next month's goals based on the latest summary and calculated growth factors
    final suggestedHours = (latestSummary.totalLoginHours * avgHoursGrowthFactor).round();
    final suggestedCalls = (latestSummary.totalCalls * avgCallsGrowthFactor).round();

    // Ensure goals are not less than current performance (unless growth factor is < 1)
    final finalSuggestedHours = suggestedHours < latestSummary.totalLoginHours ? latestSummary.totalLoginHours : suggestedHours;
    final finalSuggestedCalls = suggestedCalls < latestSummary.totalCalls ? latestSummary.totalCalls : suggestedCalls;

    return {'hours': finalSuggestedHours.toInt(), 'calls': finalSuggestedCalls.toInt()};
  }

  @override
  Future<Map<String, int>> suggestGoalsWithAI(List<MonthlySummary> historicalSummaries, Profile profile) async {
    try {
      if (historicalSummaries.isEmpty) return {'hours': 0, 'calls': 0};

      final insight = await _nlpService.suggestGoals(histories: historicalSummaries, profile: profile);
      final jsonString = insight.message.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Simple JSON parsing (avoiding adding full json_convert dependecy if possible, but manual is safer for now)
      // Assuming Gemini follows instructions well. If fails, fallback to algorithmic.
      
      // Regex extraction to be safe even if JSON is malformed
      final callsMatch = RegExp(r'"suggestedCalls":\s*(\d+)').firstMatch(jsonString);
      final hoursMatch = RegExp(r'"suggestedHours":\s*(\d+)').firstMatch(jsonString);
      
      if (callsMatch != null && hoursMatch != null) {
        return {
          'calls': int.parse(callsMatch.group(1)!),
          'hours': int.parse(hoursMatch.group(1)!),
          'reasoning': 1 // Hack to indicate success, but map is <String, int> so strictly numbers
          // Ideally we change signature, but for minimal friction we just return values
        };
      }
      return suggestGoals(historicalSummaries); // Fallback
    } catch (e) {
       return suggestGoals(historicalSummaries); // Fallback
    }
  }
}
