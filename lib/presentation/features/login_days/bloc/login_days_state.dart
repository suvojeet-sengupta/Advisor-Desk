import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

abstract class LoginDaysState extends Equatable {
  const LoginDaysState();

  @override
  List<Object> get props => [];
}

class LoginDaysInitial extends LoginDaysState {}

class LoginDaysLoading extends LoginDaysState {}

class LoginDaysLoaded extends LoginDaysState {
  final List<DailyEntry> loginEntries;
  final List<LeaveEntry> leaveEntries;
  final int presentCount;
  final int absentCount;
  final int weekOffCount;
  final int personalLeaveCount;

  const LoginDaysLoaded({
    required this.loginEntries,
    required this.leaveEntries,
    required this.presentCount,
    required this.absentCount,
    required this.weekOffCount,
    required this.personalLeaveCount,
  });

  @override
  List<Object> get props => [loginEntries, leaveEntries, presentCount, absentCount, weekOffCount, personalLeaveCount];
}

class LoginDaysError extends LoginDaysState {
  final String message;

  const LoginDaysError(this.message);

  @override
  List<Object> get props => [message];
}
