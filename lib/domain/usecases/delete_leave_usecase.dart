import 'package:advisor_desk/domain/repositories/leave_repository.dart';

class DeleteLeaveUseCase {
  final LeaveRepository repository;

  DeleteLeaveUseCase(this.repository);

  Future<void> call(DateTime date) {
    return repository.deleteLeaveEntry(date);
  }
}
