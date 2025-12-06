import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/goal_prediction_service.dart';
import 'package:advisor_desk/domain/entities/profile.dart';

class GetGoalSuggestionsUseCase {
  final PerformanceRepository repository;
  final GoalPredictionService goalPredictionService;

  GetGoalSuggestionsUseCase(this.repository, this.goalPredictionService);

  Future<Map<String, int>> execute({bool useAi = false, Profile? profile}) async {
    final summaries = await repository.getAllMonthlySummaries();
    
    if (useAi && profile != null) {
      return goalPredictionService.suggestGoalsWithAI(summaries, profile);
    }
    
    return goalPredictionService.suggestGoals(summaries);
  }
}
