import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

class MarkLeaveUseCase {
  final LeaveRepository repository;

  MarkLeaveUseCase(this.repository);

  Future<void> call(LeaveEntry entry) {
    return repository.saveLeaveEntry(entry);
  }
}
