import 'package:advisor_desk/domain/entities/leave_entry.dart';

/// An abstract repository for managing leave entries.
///
/// This class defines the contract for saving, retrieving, and deleting leave entries.
abstract class LeaveRepository {
  /// Saves a leave entry.
  ///
  /// The [entry] is the [LeaveEntry] object to be saved.
  Future<void> saveLeaveEntry(LeaveEntry entry);

  /// Retrieves all leave entries for a specific [year] and [month].
  Future<List<LeaveEntry>> getLeaveEntriesForMonth(int year, int month);

  /// Deletes a leave entry for a specific [date].
  Future<void> deleteLeaveEntry(DateTime date);
}
