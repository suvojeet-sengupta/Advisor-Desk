import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

/// The base class for all events related to adding or editing a CSAT entry.
abstract class AddCSATEntryEvent extends Equatable {
  const AddCSATEntryEvent();

  @override
  List<Object?> get props => [];
}

/// An event to initialize the CSAT entry form.
class InitializeCSATEntry extends AddCSATEntryEvent {
  /// The initial date for a new entry.
  final DateTime? date;
  /// An existing entry to be edited.
  final CSATEntry? entry;

  /// Creates an [InitializeCSATEntry] event.
  const InitializeCSATEntry({this.date, this.entry});

  @override
  List<Object?> get props => [date, entry];
}

/// An event representing a change in the date.
class CSATDateChanged extends AddCSATEntryEvent {
  /// The new date.
  final DateTime date;

  /// Creates a [CSATDateChanged] event.
  const CSATDateChanged({required this.date});

  @override
  List<Object> get props => [date];
}

/// An event representing a change in the T2 count.
class T2CountChanged extends AddCSATEntryEvent {
  /// The new T2 count.
  final int count;

  /// Creates a [T2CountChanged] event.
  const T2CountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

/// An event representing a change in the B2 count.
class B2CountChanged extends AddCSATEntryEvent {
  /// The new B2 count.
  final int count;

  /// Creates a [B2CountChanged] event.
  const B2CountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

/// An event representing a change in the N count.
class NCountChanged extends AddCSATEntryEvent {
  /// The new N count.
  final int count;

  /// Creates an [NCountChanged] event.
  const NCountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

/// An event to submit the CSAT entry.
class SubmitCSATEntry extends AddCSATEntryEvent {
  /// Creates a [SubmitCSATEntry] event.
  const SubmitCSATEntry();
}

/// An event to show a success message.
class ShowSuccessMessage extends AddCSATEntryEvent {
  /// Creates a [ShowSuccessMessage] event.
  const ShowSuccessMessage();
}

/// An event to delete a CSAT entry.
class DeleteCSATEntry extends AddCSATEntryEvent {
  /// Creates a [DeleteCSATEntry] event.
  const DeleteCSATEntry();
}
