import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for updating an existing daily performance entry.
///
/// This class encapsulates the business logic for updating a [DailyEntry].
/// It interacts with the [PerformanceRepository] to persist the changes.
class UpdateEntryUseCase {
  /// The performance repository.
  final PerformanceRepository repository;
  
  /// Creates a new instance of [UpdateEntryUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data operations.
  UpdateEntryUseCase(this.repository);
  
  /// Executes the use case.
  ///
  /// The [entry] is the [DailyEntry] to be updated.
  /// Returns the number of entries updated.
  Future<int> execute(DailyEntry entry) {
    return repository.updateEntry(entry);
  }
}
