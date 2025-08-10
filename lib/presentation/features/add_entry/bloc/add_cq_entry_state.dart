import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

enum AddCQEntryStatus { initial, loading, loaded, success, failure }

class AddCQEntryState extends Equatable {
  final AddCQEntryStatus status;
  final DateTime auditDate;
  final double percentage;
  final CQEntry? existingEntry;
  final String? errorMessage;
  final bool isDelete;

  const AddCQEntryState({
    this.status = AddCQEntryStatus.initial,
    required this.auditDate,
    this.percentage = 0.0,
    this.existingEntry,
    this.errorMessage,
    this.isDelete = false,
  });

  factory AddCQEntryState.initial() {
    return AddCQEntryState(
      auditDate: DateTime.now(),
    );
  }

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

  bool get isUpdate => existingEntry != null;

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
