import 'package:equatable/equatable.dart';

enum LeaveType {
  weekOff,
  personal,
}

class LeaveEntry extends Equatable {
  final DateTime date;
  final LeaveType type;
  final String? reason; // Optional reason for personal leave

  const LeaveEntry({
    required this.date,
    required this.type,
    this.reason,
  });

  @override
  List<Object?> get props => [date, type, reason];

  // For persistence
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'type': type.index,
      'reason': reason,
    };
  }

  factory LeaveEntry.fromMap(Map<String, dynamic> map) {
    return LeaveEntry(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: LeaveType.values[map['type']],
      reason: map['reason'],
    );
  }
}
