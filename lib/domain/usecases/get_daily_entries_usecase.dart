import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for getting all daily entries for a specific month.
///
/// This class encapsulates the business logic for retrieving a list of
/// [DailyEntry] objects for a given month and year.
class GetDailyEntriesUseCase {
  /// The performance repository.
  final PerformanceRepository repository;
  
  /// Creates a new instance of [GetDailyEntriesUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for data retrieval.
  GetDailyEntriesUseCase(this.repository);
  
  /// Executes the use case.
  ///
  /// The [month] and [year] specify the desired month.
  /// Returns a [Future] that completes with a list of [DailyEntry] objects.
  Future<List<DailyEntry>> execute(int month, int year) {
    return repository.getEntriesForMonth(month, year);
  }
}
