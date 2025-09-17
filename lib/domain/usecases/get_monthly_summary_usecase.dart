import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for getting a monthly summary.
///
/// This class encapsulates the business logic for retrieving a [MonthlySummary]
/// object for a given month and year.
class GetMonthlySummaryUseCase {
  /// The performance repository.
  final PerformanceRepository repository;
  
  /// Creates a new instance of [GetMonthlySummaryUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data retrieval.
  GetMonthlySummaryUseCase(this.repository);
  
  /// Executes the use case.
  ///
  /// The [month] and [year] specify the desired month.
  /// Returns a [Future] that completes with a [MonthlySummary] object.
  Future<MonthlySummary> execute(int month, int year) {
    return repository.getMonthlySummary(month, year);
  }
}
