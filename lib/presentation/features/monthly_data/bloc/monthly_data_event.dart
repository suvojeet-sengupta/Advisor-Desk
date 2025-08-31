import 'package:equatable/equatable.dart';

abstract class MonthlyDataEvent extends Equatable {
  const MonthlyDataEvent();

  @override
  List<Object> get props => [];
}

class LoadMonthlyData extends MonthlyDataEvent {
  final int month;
  final int year;

  const LoadMonthlyData(this.month, this.year);

  @override
  List<Object> get props => [month, year];
}

class UpdateNonBillableCalls extends MonthlyDataEvent {
  final int month;
  final int year;
  final int nonBillableCalls;

  const UpdateNonBillableCalls(this.month, this.year, this.nonBillableCalls);

  @override
  List<Object> get props => [month, year, nonBillableCalls];
}
