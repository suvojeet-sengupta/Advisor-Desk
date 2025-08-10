import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

enum AddCSATEntryStatus { initial, loading, loaded, success, failure }

class AddCSATEntryState extends Equatable {
  final AddCSATEntryStatus status;
  final DateTime date;
  final int t2Count;
  final int b2Count;
  final int nCount;
  final CSATEntry? existingEntry;
  final String? errorMessage;
  final bool isDelete;

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

  factory AddCSATEntryState.initial() {
    return AddCSATEntryState(
      date: DateTime.now(),
    );
  }

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

  bool get isUpdate => existingEntry != null;

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
