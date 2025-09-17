import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

/// The base class for all events related to the "Login Days" feature.
abstract class LoginDaysEvent extends Equatable {
  const LoginDaysEvent();

  @override
  List<Object> get props => [];
}

/// An event to load the login and leave data for a specific month.
class LoadLoginDays extends LoginDaysEvent {
  /// The year to load data for.
  final int year;
  /// The month to load data for.
  final int month;

  /// Creates a [LoadLoginDays] event.
  const LoadLoginDays(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}

/// An event to mark a day as leave.
class MarkDayAsLeave extends LoginDaysEvent {
  /// The leave entry to be saved.
  final LeaveEntry entry;

  /// Creates a [MarkDayAsLeave] event.
  const MarkDayAsLeave(this.entry);

  @override
  List<Object> get props => [entry];
}

/// An event to delete a leave entry.
class DeleteLeave extends LoginDaysEvent {
  /// The date of the leave entry to be deleted.
  final DateTime date;

  /// Creates a [DeleteLeave] event.
  const DeleteLeave(this.date);

  @override
  List<Object> get props => [date];
}
