import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

/// The base class for all events related to adding or editing a CQ entry.
abstract class AddCQEntryEvent extends Equatable {
  const AddCQEntryEvent();

  @override
  List<Object?> get props => [];
}

/// An event to initialize the CQ entry form.
class InitializeCQEntry extends AddCQEntryEvent {
  /// The initial audit date for a new entry.
  final DateTime? auditDate;
  /// An existing entry to be edited.
  final CQEntry? entry;

  /// Creates an [InitializeCQEntry] event.
  const InitializeCQEntry({this.auditDate, this.entry});

  @override
  List<Object?> get props => [auditDate, entry];
}

/// An event representing a change in the audit date.
class CQDateChanged extends AddCQEntryEvent {
  /// The new audit date.
  final DateTime auditDate;

  /// Creates a [CQDateChanged] event.
  const CQDateChanged({required this.auditDate});

  @override
  List<Object> get props => [auditDate];
}

/// An event representing a change in the percentage.
class CQPercentageChanged extends AddCQEntryEvent {
  /// The new percentage.
  final double percentage;

  /// Creates a [CQPercentageChanged] event.
  const CQPercentageChanged({required this.percentage});

  @override
  List<Object> get props => [percentage];
}

/// An event to submit the CQ entry.
class SubmitCQEntry extends AddCQEntryEvent {
  /// The CQ entry to be submitted.
  final CQEntry entry;
  /// Whether this is an update to an existing entry.
  final bool isUpdate;

  /// Creates a [SubmitCQEntry] event.
  const SubmitCQEntry({required this.entry, this.isUpdate = false});

  @override
  List<Object> get props => [entry, isUpdate];
}

/// An event to show a success message.
class ShowSuccessMessage extends AddCQEntryEvent {
  /// Creates a [ShowSuccessMessage] event.
  const ShowSuccessMessage();
}

/// An event to delete a CQ entry.
class DeleteCQEntry extends AddCQEntryEvent {
  /// Creates a [DeleteCQEntry] event.
  const DeleteCQEntry();
}
