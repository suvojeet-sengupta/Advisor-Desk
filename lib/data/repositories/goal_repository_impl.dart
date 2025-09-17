import 'package:advisor_desk/data/datasources/goal_data_source.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';

/// The implementation of the [GoalRepository] interface.
///
/// This class acts as a bridge between the domain layer and the data layer
/// for goal-related operations. It uses a [GoalDataSource] to fetch and
/// save goal data.
class GoalRepositoryImpl implements GoalRepository {
  /// The data source for goals.
  final GoalDataSource dataSource;

  /// Creates a new instance of [GoalRepositoryImpl].
  ///
  /// The [dataSource] is the [GoalDataSource] to be used for data operations.
  GoalRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, int>> getGoals() {
    return dataSource.getGoals();
  }

  @override
  Future<void> saveGoals({required int hours, required int calls}) {
    return dataSource.saveGoals(hours: hours, calls: calls);
  }
}
