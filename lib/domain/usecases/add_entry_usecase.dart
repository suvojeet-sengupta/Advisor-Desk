import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// Use case for adding a new daily performance entry.
/// 
/// This use case encapsulates the business logic for adding a daily entry
/// to the performance repository. It follows the Clean Architecture pattern
/// by separating business logic from implementation details.
/// 
/// Example usage:
/// ```dart
/// final useCase = AddEntryUseCase(performanceRepository);
/// final entry = DailyEntry(
///   date: DateTime.now(),
///   loginHours: 8,
///   loginMinutes: 30,
///   callCount: 50,
/// );
/// final entryId = await useCase.execute(entry);
/// ```
class AddEntryUseCase {
  final PerformanceRepository repository;
  
  /// Creates an instance of [AddEntryUseCase] with the given [repository].
  AddEntryUseCase(this.repository);
  
  /// Executes the use case to add a new daily entry.
  /// 
  /// Parameters:
  /// - [entry]: The daily entry to be added to the repository
  /// 
  /// Returns:
  /// - The ID of the newly added entry
  /// 
  /// Throws:
  /// - Exception if the entry cannot be added to the repository
  Future<int> execute(DailyEntry entry) {
    return repository.addEntry(entry);
  }
}
