import 'package:equatable/equatable.dart';

/// Defines the type of leave.
enum LeaveType {
  /// A scheduled day off, typically a weekend.
  weekOff,
  /// A leave taken for personal reasons.
  personal,
}

/// Represents a single leave entry for a specific day.
///
/// This class encapsulates the date of the leave, the type of leave, and an
/// optional reason.
class LeaveEntry extends Equatable {
  /// The date of the leave.
  final DateTime date;
  /// The type of leave (e.g., week off, personal).
  final LeaveType type;
  /// An optional reason for the leave, typically for personal leave.
  final String? reason;

  /// Creates a new instance of [LeaveEntry].
  ///
  /// The [date] and [type] are required. The [reason] is optional.
  const LeaveEntry({
    required this.date,
    required this.type,
    this.reason,
  });

  @override
  List<Object?> get props => [date, type, reason];

  /// Converts this [LeaveEntry] object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'type': type.index,
      'reason': reason,
    };
  }

  /// Creates a [LeaveEntry] object from a map retrieved from the database.
  factory LeaveEntry.fromMap(Map<String, dynamic> map) {
    return LeaveEntry(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: LeaveType.values[map['type']],
      reason: map['reason'],
    );
  }
}
