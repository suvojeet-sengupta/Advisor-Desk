import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

/// A use case for getting all leave entries for a specific month.
///
/// This class encapsulates the business logic for retrieving a list of
/// [LeaveEntry] objects for a given month and year.
class GetLeaveEntriesUseCase {
  /// The leave repository.
  final LeaveRepository repository;

  /// Creates a new instance of [GetLeaveEntriesUseCase].
  ///
  /// The [repository] is the [LeaveRepository] to be used for data retrieval.
  GetLeaveEntriesUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [year] and [month] specify the desired month.
  /// Returns a [Future] that completes with a list of [LeaveEntry] objects.
  Future<List<LeaveEntry>> call(int year, int month) {
    return repository.getLeaveEntriesForMonth(year, month);
  }
}
