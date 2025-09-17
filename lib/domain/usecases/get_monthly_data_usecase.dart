import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for getting additional monthly data.
///
/// This class encapsulates the business logic for retrieving a [MonthlyData]
/// object for a given month and year.
class GetMonthlyDataUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [GetMonthlyDataUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data retrieval.
  GetMonthlyDataUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [month] and [year] specify the desired month.
  /// Returns a [Future] that completes with a [MonthlyData] object, or null if not found.
  Future<MonthlyData?> execute(int month, int year) {
    return repository.getMonthlyData(month, year);
  }
}
