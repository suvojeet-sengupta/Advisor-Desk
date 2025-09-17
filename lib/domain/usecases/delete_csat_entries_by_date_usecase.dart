import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for deleting all Customer Satisfaction (CSAT) entries for a specific date.
///
/// This class encapsulates the business logic for deleting CSAT entries.
/// It interacts with the [PerformanceRepository] to perform the deletion.
class DeleteCSATEntriesByDateUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [DeleteCSATEntriesByDateUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for the deletion.
  DeleteCSATEntriesByDateUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [date] is the date for which to delete the CSAT entries.
  /// Returns the number of entries deleted.
  Future<int> execute(DateTime date) {
    return repository.deleteCSATEntriesByDate(date);
  }
}
