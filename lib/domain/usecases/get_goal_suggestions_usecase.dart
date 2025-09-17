import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for getting goal suggestions based on past performance.
///
/// This class calculates average performance over the last 3 months and suggests
/// a 10% increase for the new goals.
class GetGoalSuggestionsUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [GetGoalSuggestionsUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data retrieval.
  GetGoalSuggestionsUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Returns a [Future] that completes with a map containing suggested 'hours' and 'calls'.
  Future<Map<String, int>> execute() async {
    final summaries = await repository.getAllMonthlySummaries();

    if (summaries.isEmpty) {
      return {'hours': 0, 'calls': 0};
    }

    // Take the last 3 months for calculating the average
    final recentSummaries = summaries.length > 3 ? summaries.sublist(0, 3) : summaries;

    double totalHours = 0;
    int totalCalls = 0;

    for (final summary in recentSummaries) {
      totalHours += summary.totalLoginHours;
      totalCalls += summary.totalCalls;
    }

    final avgHours = totalHours / recentSummaries.length;
    final avgCalls = totalCalls / recentSummaries.length;

    // Suggest a 10% increase
    final suggestedHours = (avgHours * 1.1).round();
    final suggestedCalls = (avgCalls * 1.1).round();

    return {'hours': suggestedHours, 'calls': suggestedCalls};
  }
}
