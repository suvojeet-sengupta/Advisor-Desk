import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

/// The base class for all states related to the "Login Days" feature.
abstract class LoginDaysState extends Equatable {
  const LoginDaysState();

  @override
  List<Object> get props => [];
}

/// The initial state of the "Login Days" feature.
class LoginDaysInitial extends LoginDaysState {}

/// The state indicating that the login days data is being loaded.
class LoginDaysLoading extends LoginDaysState {}

/// The state indicating that the login days data has been successfully loaded.
class LoginDaysLoaded extends LoginDaysState {
  /// The list of daily entries for the month.
  final List<DailyEntry> loginEntries;
  /// The list of leave entries for the month.
  final List<LeaveEntry> leaveEntries;
  /// The number of present days.
  final int presentCount;
  /// The number of absent days.
  final int absentCount;
  /// The number of week-off days.
  final int weekOffCount;
  /// The number of personal leave days.
  final int personalLeaveCount;

  /// Creates a [LoginDaysLoaded] state.
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

/// The state indicating that an error occurred while loading the login days data.
class LoginDaysError extends LoginDaysState {
  /// The error message.
  final String message;

  /// Creates a [LoginDaysError] state.
  const LoginDaysError(this.message);

  @override
  List<Object> get props => [message];
}
