import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

abstract class AddCQEntryEvent extends Equatable {
  const AddCQEntryEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCQEntry extends AddCQEntryEvent {
  final DateTime? auditDate;
  final CQEntry? entry;

  const InitializeCQEntry({this.auditDate, this.entry});

  @override
  List<Object?> get props => [auditDate, entry];
}

class CQDateChanged extends AddCQEntryEvent {
  final DateTime auditDate;

  const CQDateChanged({required this.auditDate});

  @override
  List<Object> get props => [auditDate];
}

class CQPercentageChanged extends AddCQEntryEvent {
  final double percentage;

  const CQPercentageChanged({required this.percentage});

  @override
  List<Object> get props => [percentage];
}

class SubmitCQEntry extends AddCQEntryEvent {
  const SubmitCQEntry();
}

class ShowSuccessMessage extends AddCQEntryEvent {
  const ShowSuccessMessage();
}

class DeleteCQEntry extends AddCQEntryEvent {
  const DeleteCQEntry();
}
