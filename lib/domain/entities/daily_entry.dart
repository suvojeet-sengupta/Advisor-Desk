import 'package:equatable/equatable.dart';

/// Represents a single daily performance entry.
///
/// This class encapsulates the details of a user's performance on a specific day,
/// including login time and the number of calls made. It also provides helper
/// methods for time calculations and formatting.
class DailyEntry extends Equatable {
  /// The unique identifier for the entry. Can be null if the entry is not yet saved.
  final int? id;
  /// The date of the performance entry.
  final DateTime date;
  /// The hours part of the total login time.
  final int loginHours;
  /// The minutes part of the total login time.
  final int loginMinutes;
  /// The seconds part of the total login time.
  final int loginSeconds;
  /// The total number of calls made on this day.
  final int callCount;

  /// Creates a new instance of [DailyEntry].
  const DailyEntry({
    this.id,
    required this.date,
    required this.loginHours,
    required this.loginMinutes,
    required this.loginSeconds,
    required this.callCount,
  });

  /// The total login time in seconds.
  int get totalLoginTimeInSeconds {
    return (loginHours * 3600) + (loginMinutes * 60) + loginSeconds;
  }

  /// The total login time in hours, as a double for calculations.
  double get totalLoginTimeInHours {
    return loginHours + (loginMinutes / 60) + (loginSeconds / 3600);
  }

  /// The formatted login time in HH:MM:SS format.
  String get formattedLoginTime {
    return '${'${loginHours}'.padLeft(2, '0')}:${'${loginMinutes}'.padLeft(2, '0')}:${'${loginSeconds}'.padLeft(2, '0')}';
  }

  /// Creates a copy of this [DailyEntry] but with the given fields replaced with new values.
  DailyEntry copyWith({
    int? id,
    DateTime? date,
    int? loginHours,
    int? loginMinutes,
    int? loginSeconds,
    int? callCount,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      loginHours: loginHours ?? this.loginHours,
      loginMinutes: loginMinutes ?? this.loginMinutes,
      loginSeconds: loginSeconds ?? this.loginSeconds,
      callCount: callCount ?? this.callCount,
    );
  }

  /// Converts this [DailyEntry] object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'login_hours': loginHours,
      'login_minutes': loginMinutes,
      'login_seconds': loginSeconds,
      'call_count': callCount,
    };
  }

  /// Creates a [DailyEntry] object from a map retrieved from the database.
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      loginHours: map['login_hours'],
      loginMinutes: map['login_minutes'],
      loginSeconds: map['login_seconds'],
      callCount: map['call_count'],
    );
  }

  @override
  List<Object?> get props => [id, date, loginHours, loginMinutes, loginSeconds, callCount];
}