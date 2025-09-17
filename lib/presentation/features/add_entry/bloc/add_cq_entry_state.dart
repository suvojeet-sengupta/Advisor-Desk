import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

/// The status of the add/edit CQ entry operation.
enum AddCQEntryStatus { initial, loading, loaded, success, failure }

/// The state for the Add/Edit CQ Entry feature.
///
/// This class holds all the data related to the state of the form,
/// including the current status, input values, and any error messages.
class AddCQEntryState extends Equatable {
  /// The current status of the operation.
  final AddCQEntryStatus status;
  /// The audit date of the CQ entry.
  final DateTime auditDate;
  /// The percentage of the CQ entry.
  final double percentage;
  /// The existing CQ entry, if one is being edited.
  final CQEntry? existingEntry;
  /// An error message, if any.
  final String? errorMessage;
  /// Whether the entry has been deleted.
  final bool isDelete;

  /// Creates a new instance of [AddCQEntryState].
  const AddCQEntryState({
    this.status = AddCQEntryStatus.initial,
    required this.auditDate,
    this.percentage = 0.0,
    this.existingEntry,
    this.errorMessage,
    this.isDelete = false,
  });

  /// Creates an initial state with the current date.
  factory AddCQEntryState.initial() {
    return AddCQEntryState(
      auditDate: DateTime.now(),
    );
  }

  /// Creates a copy of this state but with the given fields replaced with new values.
  AddCQEntryState copyWith({
    AddCQEntryStatus? status,
    DateTime? auditDate,
    double? percentage,
    CQEntry? existingEntry,
    String? errorMessage,
    bool? isDelete,
  }) {
    return AddCQEntryState(
      status: status ?? this.status,
      auditDate: auditDate ?? this.auditDate,
      percentage: percentage ?? this.percentage,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  /// Whether the form is in update mode.
  bool get isUpdate => existingEntry != null;

  /// Creates a [CQEntry] from the current state.
  CQEntry toEntry() {
    return CQEntry(
      id: existingEntry?.id,
      auditDate: auditDate,
      percentage: percentage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        auditDate,
        percentage,
        existingEntry,
        errorMessage,
        isDelete,
      ];
}
