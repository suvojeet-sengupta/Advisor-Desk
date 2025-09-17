import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

/// The status of the add/edit CSAT entry operation.
enum AddCSATEntryStatus { initial, loading, loaded, success, failure }

/// The state for the Add/Edit CSAT Entry feature.
///
/// This class holds all the data related to the state of the form,
/// including the current status, input values, and any error messages.
class AddCSATEntryState extends Equatable {
  /// The current status of the operation.
  final AddCSATEntryStatus status;
  /// The date of the CSAT entry.
  final DateTime date;
  /// The T2 count of the CSAT entry.
  final int t2Count;
  /// The B2 count of the CSAT entry.
  final int b2Count;
  /// The N count of the CSAT entry.
  final int nCount;
  /// The existing CSAT entry, if one is being edited.
  final CSATEntry? existingEntry;
  /// An error message, if any.
  final String? errorMessage;
  /// Whether the entry has been deleted.
  final bool isDelete;

  /// Creates a new instance of [AddCSATEntryState].
  const AddCSATEntryState({
    this.status = AddCSATEntryStatus.initial,
    required this.date,
    this.t2Count = 0,
    this.b2Count = 0,
    this.nCount = 0,
    this.existingEntry,
    this.errorMessage,
    this.isDelete = false,
  });

  /// Creates an initial state with the current date.
  factory AddCSATEntryState.initial() {
    return AddCSATEntryState(
      date: DateTime.now(),
    );
  }

  /// Creates a copy of this state but with the given fields replaced with new values.
  AddCSATEntryState copyWith({
    AddCSATEntryStatus? status,
    DateTime? date,
    int? t2Count,
    int? b2Count,
    int? nCount,
    CSATEntry? existingEntry,
    String? errorMessage,
    bool? isDelete,
  }) {
    return AddCSATEntryState(
      status: status ?? this.status,
      date: date ?? this.date,
      t2Count: t2Count ?? this.t2Count,
      b2Count: b2Count ?? this.b2Count,
      nCount: nCount ?? this.nCount,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  /// Whether the form is in update mode.
  bool get isUpdate => existingEntry != null;

  /// Creates a [CSATEntry] from the current state.
  CSATEntry toEntry() {
    return CSATEntry(
      id: existingEntry?.id,
      date: date,
      t2Count: t2Count,
      b2Count: b2Count,
      nCount: nCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        date,
        t2Count,
        b2Count,
        nCount,
        existingEntry,
        errorMessage,
        isDelete,
      ];
}
