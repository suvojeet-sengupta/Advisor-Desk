import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for adding a new daily performance entry.
///
/// This class encapsulates the business logic for adding a new [DailyEntry].
/// It interacts with the [PerformanceRepository] to persist the data.
class AddEntryUseCase {
  /// The performance repository.
  final PerformanceRepository repository;
  
  /// Creates a new instance of [AddEntryUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data operations.
  AddEntryUseCase(this.repository);
  
  /// Executes the use case.
  ///
  /// The [entry] is the [DailyEntry] to be added.
  /// Returns the ID of the newly added entry.
  Future<int> execute(DailyEntry entry) {
    return repository.addEntry(entry);
  }
}
