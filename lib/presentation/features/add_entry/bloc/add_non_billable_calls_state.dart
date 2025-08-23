import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

enum AddNonBillableCallsStatus { initial, loading, loaded, success, failure }

class AddNonBillableCallsState extends Equatable {
  final AddNonBillableCallsStatus status;
  final DateTime date;
  final int nonBillableCalls;
  final DailyEntry? existingEntry;
  final String? errorMessage;

  const AddNonBillableCallsState({
    this.status = AddNonBillableCallsStatus.initial,
    required this.date,
    this.nonBillableCalls = 0,
    this.existingEntry,
    this.errorMessage,
  });

  factory AddNonBillableCallsState.initial() {
    return AddNonBillableCallsState(
      date: DateTime.now(),
    );
  }

  AddNonBillableCallsState copyWith({
    AddNonBillableCallsStatus? status,
    DateTime? date,
    int? nonBillableCalls,
    DailyEntry? existingEntry,
    String? errorMessage,
  }) {
    return AddNonBillableCallsState(
      status: status ?? this.status,
      date: date ?? this.date,
      nonBillableCalls: nonBillableCalls ?? this.nonBillableCalls,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
    );
  }

  bool get isUpdate => existingEntry != null;

  @override
  List<Object?> get props => [
        status,
        date,
        nonBillableCalls,
        existingEntry,
        errorMessage,
      ];
}
