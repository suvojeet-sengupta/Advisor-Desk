import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

/// The base class for all events related to adding or editing a daily entry.
abstract class AddEntryEvent extends Equatable {
  const AddEntryEvent();

  @override
  List<Object?> get props => [];
}

/// An event to initialize the daily entry form.
class InitializeAddEntry extends AddEntryEvent {
  /// The initial date for a new entry.
  final DateTime? date;
  /// An existing entry to be edited.
  final DailyEntry? entry;

  /// Creates an [InitializeAddEntry] event.
  const InitializeAddEntry({this.date, this.entry});

  @override
  List<Object?> get props => [date, entry];
}

/// An event representing a change in the date.
class DateChanged extends AddEntryEvent {
  /// The new date.
  final DateTime date;

  /// Creates a [DateChanged] event.
  const DateChanged({required this.date});

  @override
  List<Object> get props => [date];
}

/// An event representing a change in the login hours.
class LoginHoursChanged extends AddEntryEvent {
  /// The new login hours.
  final int hours;

  /// Creates a [LoginHoursChanged] event.
  const LoginHoursChanged({required this.hours});

  @override
  List<Object> get props => [hours];
}

/// An event representing a change in the login minutes.
class LoginMinutesChanged extends AddEntryEvent {
  /// The new login minutes.
  final int minutes;

  /// Creates a [LoginMinutesChanged] event.
  const LoginMinutesChanged({required this.minutes});

  @override
  List<Object> get props => [minutes];
}

/// An event representing a change in the login seconds.
class LoginSecondsChanged extends AddEntryEvent {
  /// The new login seconds.
  final int seconds;

  /// Creates a [LoginSecondsChanged] event.
  const LoginSecondsChanged({required this.seconds});

  @override
  List<Object> get props => [seconds];
}

/// An event representing a change in the call count.
class CallCountChanged extends AddEntryEvent {
  /// The new call count.
  final int callCount;

  /// Creates a [CallCountChanged] event.
  const CallCountChanged({required this.callCount});

  @override
  List<Object> get props => [callCount];
}

/// An event representing a change in the non-billable calls.
class NonBillableCallsChanged extends AddEntryEvent {
  /// The new non-billable call count.
  final int nonBillableCalls;

  /// Creates a [NonBillableCallsChanged] event.
  const NonBillableCallsChanged({required this.nonBillableCalls});

  @override
  List<Object> get props => [nonBillableCalls];
}

/// An event to submit the daily entry.
class SubmitEntry extends AddEntryEvent {
  /// Creates a [SubmitEntry] event.
  const SubmitEntry();
}

/// An event to show a success message.
class ShowSuccessMessage extends AddEntryEvent {
  /// Creates a [ShowSuccessMessage] event.
  const ShowSuccessMessage();
}

// The new delete event is added here
/// An event to delete a daily entry.
class DeleteEntry extends AddEntryEvent {
  /// Creates a [DeleteEntry] event.
  const DeleteEntry();
}
