import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

/// The status of the add/edit daily entry operation.
enum AddEntryStatus { initial, loading, loaded, success, failure }

/// The state for the Add/Edit Daily Entry feature.
///
/// This class holds all the data related to the state of the form,
/// including the current status, input values, and any error messages.
class AddEntryState extends Equatable {
  /// The current status of the operation.
  final AddEntryStatus status;
  /// The date of the daily entry.
  final DateTime date;
  /// The login hours of the daily entry.
  final int loginHours;
  /// The login minutes of the daily entry.
  final int loginMinutes;
  /// The login seconds of the daily entry.
  final int loginSeconds;
  /// The call count of the daily entry.
  final int callCount;
  /// The existing daily entry, if one is being edited.
  final DailyEntry? existingEntry;
  /// An error message, if any.
  final String? errorMessage;
  /// Whether the entry has been deleted.
  final bool isDelete;

  /// Creates a new instance of [AddEntryState].
  const AddEntryState({
    this.status = AddEntryStatus.initial,
    required this.date,
    this.loginHours = 0,
    this.loginMinutes = 0,
    this.loginSeconds = 0,
    this.callCount = 0,
    this.existingEntry,
    this.errorMessage,
    this.isDelete = false,
  });

  /// Creates an initial state with the current date.
  factory AddEntryState.initial() {
    return AddEntryState(
      date: DateTime.now(),
    );
  }

  /// Creates a copy of this state but with the given fields replaced with new values.
  AddEntryState copyWith({
    AddEntryStatus? status,
    DateTime? date,
    int? loginHours,
    int? loginMinutes,
    int? loginSeconds,
    int? callCount,
    DailyEntry? existingEntry,
    String? errorMessage,
    bool? isDelete,
  }) {
    return AddEntryState(
      status: status ?? this.status,
      date: date ?? this.date,
      loginHours: loginHours ?? this.loginHours,
      loginMinutes: loginMinutes ?? this.loginMinutes,
      loginSeconds: loginSeconds ?? this.loginSeconds,
      callCount: callCount ?? this.callCount,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  /// Whether the input values are valid.
  bool get isValid {
    return loginHours >= 0 &&
        loginHours < 24 &&
        loginMinutes >= 0 &&
        loginMinutes < 60 &&
        loginSeconds >= 0 &&
        loginSeconds < 60 &&
        callCount >= 0 &&
        (loginHours > 0 || loginMinutes > 0 || loginSeconds > 0 || callCount > 0);
  }

  /// Whether the form is in update mode.
  bool get isUpdate => existingEntry != null;

  /// Creates a [DailyEntry] from the current state.
  DailyEntry toEntry() {
    return DailyEntry(
      id: existingEntry?.id,
      date: date,
      loginHours: loginHours,
      loginMinutes: loginMinutes,
      loginSeconds: loginSeconds,
      callCount: callCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        date,
        loginHours,
        loginMinutes,
        loginSeconds,
        callCount,
        existingEntry,
        errorMessage,
        isDelete,
      ];
}
