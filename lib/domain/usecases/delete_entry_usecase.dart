import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for deleting a daily performance entry.
///
/// This class encapsulates the business logic for deleting a daily entry
/// by its ID. It interacts with the [PerformanceRepository] to perform the deletion.
class DeleteEntryUseCase {
  /// The performance repository.
  final PerformanceRepository repository;
  
  /// Creates a new instance of [DeleteEntryUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for the deletion.
  DeleteEntryUseCase(this.repository);
  
  /// Executes the use case.
  ///
  /// The [id] is the ID of the daily entry to be deleted.
  /// Returns the number of entries deleted.
  Future<int> execute(int id) {
    return repository.deleteEntry(id);
  }
}
