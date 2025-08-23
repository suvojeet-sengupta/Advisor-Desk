import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

enum AddEntryStatus { initial, loading, loaded, success, failure }

class AddEntryState extends Equatable {
  final AddEntryStatus status;
  final DateTime date;
  final int loginHours;
  final int loginMinutes;
  final int loginSeconds;
  final int callCount;
  final int nonBillableCalls;
  final DailyEntry? existingEntry;
  final String? errorMessage;
  final bool isDelete; // नया फ्लैग

  const AddEntryState({
    this.status = AddEntryStatus.initial,
    required this.date,
    this.loginHours = 0,
    this.loginMinutes = 0,
    this.loginSeconds = 0,
    this.callCount = 0,
    this.nonBillableCalls = 0,
    this.existingEntry,
    this.errorMessage,
    this.isDelete = false, // डिफ़ॉल्ट वैल्यू
  });

  factory AddEntryState.initial() {
    return AddEntryState(
      date: DateTime.now(),
    );
  }

  AddEntryState copyWith({
    AddEntryStatus? status,
    DateTime? date,
    int? loginHours,
    int? loginMinutes,
    int? loginSeconds,
    int? callCount,
    int? nonBillableCalls,
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
      nonBillableCalls: nonBillableCalls ?? this.nonBillableCalls,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  bool get isValid {
    return loginHours >= 0 &&
        loginHours < 24 &&
        loginMinutes >= 0 &&
        loginMinutes < 60 &&
        loginSeconds >= 0 &&
        loginSeconds < 60 &&
        callCount >= 0 &&
        nonBillableCalls >= 0 &&
        callCount >= nonBillableCalls &&
        (loginHours > 0 || loginMinutes > 0 || loginSeconds > 0 || callCount > 0);
  }

  bool get isUpdate => existingEntry != null;

  DailyEntry toEntry() {
    return DailyEntry(
      id: existingEntry?.id,
      date: date,
      loginHours: loginHours,
      loginMinutes: loginMinutes,
      loginSeconds: loginSeconds,
      callCount: callCount,
      nonBillableCalls: nonBillableCalls,
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
        nonBillableCalls,
        existingEntry,
        errorMessage,
        isDelete,
      ];
}
