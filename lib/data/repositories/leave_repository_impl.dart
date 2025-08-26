import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LocalDataSource localDataSource;

  LeaveRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveLeaveEntry(LeaveEntry entry) {
    return localDataSource.saveLeaveEntry(entry);
  }

  @override
  Future<List<LeaveEntry>> getLeaveEntriesForMonth(int year, int month) {
    return localDataSource.getLeaveEntriesForMonth(year, month);
  }

  @override
  Future<void> deleteLeaveEntry(DateTime date) {
    return localDataSource.deleteLeaveEntry(date);
  }
}
