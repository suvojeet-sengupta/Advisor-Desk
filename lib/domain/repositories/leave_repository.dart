import 'package:advisor_desk/domain/entities/leave_entry.dart';

abstract class LeaveRepository {
  Future<void> saveLeaveEntry(LeaveEntry entry);
  Future<List<LeaveEntry>> getLeaveEntriesForMonth(int year, int month);
  Future<void> deleteLeaveEntry(DateTime date);
}
