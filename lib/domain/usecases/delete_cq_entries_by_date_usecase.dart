import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for deleting all Call Quality (CQ) entries for a specific date.
///
/// This class encapsulates the business logic for deleting CQ entries.
/// It interacts with the [PerformanceRepository] to perform the deletion.
class DeleteCQEntriesByDateUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [DeleteCQEntriesByDateUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for the deletion.
  DeleteCQEntriesByDateUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [date] is the date for which to delete the CQ entries.
  /// Returns the number of entries deleted.
  Future<int> execute(DateTime date) {
    return repository.deleteCQEntriesByDate(date);
  }
}
