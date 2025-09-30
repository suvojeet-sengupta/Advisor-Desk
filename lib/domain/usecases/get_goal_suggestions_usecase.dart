import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/goal_prediction_service.dart';

class GetGoalSuggestionsUseCase {
  final PerformanceRepository repository;
  final GoalPredictionService goalPredictionService;

  GetGoalSuggestionsUseCase(this.repository, this.goalPredictionService);

  Future<Map<String, int>> execute() async {
    final summaries = await repository.getAllMonthlySummaries();
    return goalPredictionService.suggestGoals(summaries);
  }
}
