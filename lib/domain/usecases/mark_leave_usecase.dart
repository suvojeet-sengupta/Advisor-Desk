import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

/// A use case for marking a day as leave.
///
/// This class encapsulates the business logic for saving a [LeaveEntry].
/// It interacts with the [LeaveRepository] to persist the data.
class MarkLeaveUseCase {
  /// The leave repository.
  final LeaveRepository repository;

  /// Creates a new instance of [MarkLeaveUseCase].
  ///
  /// The [repository] is the [LeaveRepository] to be used for data operations.
  MarkLeaveUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [entry] is the [LeaveEntry] to be saved.
  Future<void> call(LeaveEntry entry) {
    return repository.saveLeaveEntry(entry);
  }
}
