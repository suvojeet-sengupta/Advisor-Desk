import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

/// The implementation of the [LeaveRepository] interface.
///
/// This class handles the communication between the domain layer and the
/// data layer for leave-related operations. It uses a [LocalDataSource] to
/// interact with the database.
class LeaveRepositoryImpl implements LeaveRepository {
  /// The local data source for database operations.
  final LocalDataSource localDataSource;

  /// Creates a new instance of [LeaveRepositoryImpl].
  ///
  /// The [localDataSource] is the [LocalDataSource] to be used for database operations.
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
