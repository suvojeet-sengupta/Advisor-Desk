import 'package:equatable/equatable.dart';

class MonthlyData extends Equatable {
  final int month;
  final int year;
  final int nonBillableCalls;

  const MonthlyData({
    required this.month,
    required this.year,
    this.nonBillableCalls = 0,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'non_billable_calls': nonBillableCalls,
    };
  }

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
