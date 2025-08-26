import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

class GetLeaveEntriesUseCase {
  final LeaveRepository repository;

  GetLeaveEntriesUseCase(this.repository);

  Future<List<LeaveEntry>> call(int year, int month) {
    return repository.getLeaveEntriesForMonth(year, month);
  }
}
