import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for saving additional monthly data.
///
/// This class encapsulates the business logic for saving a [MonthlyData] object.
/// It interacts with the [PerformanceRepository] to persist the data.
class SaveMonthlyDataUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [SaveMonthlyDataUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data operations.
  SaveMonthlyDataUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [monthlyData] is the [MonthlyData] object to be saved.
  Future<void> execute(MonthlyData monthlyData) {
    return repository.saveMonthlyData(monthlyData);
  }
}
