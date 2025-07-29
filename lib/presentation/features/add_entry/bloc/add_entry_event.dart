import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

abstract class AddEntryEvent extends Equatable {
  const AddEntryEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAddEntry extends AddEntryEvent {
  final DateTime? date;
  final DailyEntry? entry;

  const InitializeAddEntry({this.date, this.entry});

  @override
  List<Object?> get props => [date, entry];
}

class DateChanged extends AddEntryEvent {
  final DateTime date;

  const DateChanged({required this.date});

  @override
  List<Object> get props => [date];
}

class LoginHoursChanged extends AddEntryEvent {
  final int hours;

  const LoginHoursChanged({required this.hours});

  @override
  List<Object> get props => [hours];
}

class LoginMinutesChanged extends AddEntryEvent {
  final int minutes;

  const LoginMinutesChanged({required this.minutes});

  @override
  List<Object> get props => [minutes];
}

class LoginSecondsChanged extends AddEntryEvent {
  final int seconds;

  const LoginSecondsChanged({required this.seconds});

  @override
  List<Object> get props => [seconds];
}

class CallCountChanged extends AddEntryEvent {
  final int callCount;

  const CallCountChanged({required this.callCount});

  @override
  List<Object> get props => [callCount];
}

class SubmitEntry extends AddEntryEvent {
  const SubmitEntry();
}

// नया डिलीट इवेंट यहाँ जोड़ा गया है
class DeleteEntry extends AddEntryEvent {
  const DeleteEntry();
}
