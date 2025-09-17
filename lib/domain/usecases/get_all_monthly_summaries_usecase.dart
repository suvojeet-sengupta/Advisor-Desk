import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for getting all monthly summaries.
///
/// This class encapsulates the business logic for retrieving a list of
/// [MonthlySummary] objects for all months that have data.
class GetAllMonthlySummariesUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [GetAllMonthlySummariesUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data retrieval.
  GetAllMonthlySummariesUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Returns a [Future] that completes with a list of [MonthlySummary] objects.
  Future<List<MonthlySummary>> execute() {
    // Fetch the summaries directly from the repository and return them.
    return repository.getAllMonthlySummaries();
  }
}
