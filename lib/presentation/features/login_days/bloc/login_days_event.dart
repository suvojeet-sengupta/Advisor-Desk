import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

abstract class LoginDaysEvent extends Equatable {
  const LoginDaysEvent();

  @override
  List<Object> get props => [];
}

class LoadLoginDays extends LoginDaysEvent {
  final int year;
  final int month;

  const LoadLoginDays(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}

class MarkDayAsLeave extends LoginDaysEvent {
  final LeaveEntry entry;

  const MarkDayAsLeave(this.entry);

  @override
  List<Object> get props => [entry];
}

class DeleteLeave extends LoginDaysEvent {
  final DateTime date;

  const DeleteLeave(this.date);

  @override
  List<Object> get props => [date];
}
