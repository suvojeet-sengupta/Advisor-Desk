import 'package:advisor_desk/data/datasources/goal_data_source.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalDataSource dataSource;

  GoalRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> getGoals({required String userId}) {
    return dataSource.getGoals(userId: userId);
  }

  @override
  Future<void> saveGoals({required int hours, required int calls, required String userId}) {
    return dataSource.saveGoals(hours: hours, calls: calls, userId: userId);
  }
}
