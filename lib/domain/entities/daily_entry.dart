import 'package:equatable/equatable.dart';

class DailyEntry extends Equatable {
  final int? id;
  final DateTime date;
  final int loginHours;
  final int loginMinutes;
  final int loginSeconds;
  final int callCount;
  final double? customCallRate;

  const DailyEntry({
    this.id,
    required this.date,
    required this.loginHours,
    required this.loginMinutes,
    required this.loginSeconds,
    required this.callCount,
    this.customCallRate,
  });

  // Total login time in seconds
  int get totalLoginTimeInSeconds {
    return (loginHours * 3600) + (loginMinutes * 60) + loginSeconds;
  }

  // Total login time in hours (as double for calculations)
  double get totalLoginTimeInHours {
    return loginHours + (loginMinutes / 60) + (loginSeconds / 3600);
  }

  // Format login time as HH:MM:SS
  String get formattedLoginTime {
    return '${'${loginHours}'.padLeft(2, '0')}:${'${loginMinutes}'.padLeft(2, '0')}:${'${loginSeconds}'.padLeft(2, '0')}';
  }

  // Copy with method for creating a new instance with some updated values
  DailyEntry copyWith({
    int? id,
    DateTime? date,
    int? loginHours,
    int? loginMinutes,
    int? loginSeconds,
    int? callCount,
    double? customCallRate,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      loginHours: loginHours ?? this.loginHours,
      loginMinutes: loginMinutes ?? this.loginMinutes,
      loginSeconds: loginSeconds ?? this.loginSeconds,
      callCount: callCount ?? this.callCount,
      customCallRate: customCallRate ?? this.customCallRate,
    );
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'login_hours': loginHours,
      'login_minutes': loginMinutes,
      'login_seconds': loginSeconds,
      'call_count': callCount,
      'custom_call_rate': customCallRate,
    };
  }

  // Create from Map for database operations
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      loginHours: map['login_hours'],
      loginMinutes: map['login_minutes'],
      loginSeconds: map['login_seconds'],
      callCount: map['call_count'],
      customCallRate: map['custom_call_rate'],
    );
  }

  @override
  List<Object?> get props => [id, date, loginHours, loginMinutes, loginSeconds, callCount, customCallRate];
}