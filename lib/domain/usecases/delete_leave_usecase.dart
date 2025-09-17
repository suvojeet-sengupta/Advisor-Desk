import 'package:advisor_desk/domain/repositories/leave_repository.dart';

/// A use case for deleting a leave entry.
///
/// This class encapsulates the business logic for deleting a leave entry
/// for a specific date. It interacts with the [LeaveRepository] to perform the deletion.
class DeleteLeaveUseCase {
  /// The leave repository.
  final LeaveRepository repository;

  /// Creates a new instance of [DeleteLeaveUseCase].
  ///
  /// The [repository] is the [LeaveRepository] to be used for the deletion.
  DeleteLeaveUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [date] is the date of the leave entry to be deleted.
  Future<void> call(DateTime date) {
    return repository.deleteLeaveEntry(date);
  }
}
