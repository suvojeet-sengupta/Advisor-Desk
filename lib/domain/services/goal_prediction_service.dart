import 'package:advisor_desk/domain/entities/monthly_summary.dart';

abstract class GoalPredictionService {
  Future<Map<String, int>> suggestGoals(List<MonthlySummary> historicalSummaries);
}

class GoalPredictionServiceImpl implements GoalPredictionService {
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
}
