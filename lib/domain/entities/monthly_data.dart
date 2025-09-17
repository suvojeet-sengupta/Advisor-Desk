import 'package:equatable/equatable.dart';

/// Represents additional data for a specific month that doesn't fit into daily entries.
///
/// This class is used to store monthly aggregate data, such as the number of
/// non-billable calls.
class MonthlyData extends Equatable {
  /// The month of the data (1-12).
  final int month;
  /// The year of the data.
  final int year;
  /// The number of non-billable calls for the month.
  final int nonBillableCalls;

  /// Creates a new instance of [MonthlyData].
  ///
  /// The [month] and [year] are required.
  const MonthlyData({
    required this.month,
    required this.year,
    this.nonBillableCalls = 0,
  });

  /// Creates a copy of this [MonthlyData] but with the given fields replaced with new values.
  MonthlyData copyWith({
    int? month,
    int? year,
    int? nonBillableCalls,
  }) {
    return MonthlyData(
      month: month ?? this.month,
      year: year ?? this.year,
      nonBillableCalls: nonBillableCalls ?? this.nonBillableCalls,
    );
  }

  /// Converts this [MonthlyData] object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'non_billable_calls': nonBillableCalls,
    };
  }

  /// Creates a [MonthlyData] object from a map retrieved from the database.
  factory MonthlyData.fromMap(Map<String, dynamic> map) {
    return MonthlyData(
      month: map['month'],
      year: map['year'],
      nonBillableCalls: map['non_billable_calls'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [month, year, nonBillableCalls];
}
