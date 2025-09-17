import 'package:equatable/equatable.dart';

/// The base class for all events related to additional monthly data.
abstract class MonthlyDataEvent extends Equatable {
  const MonthlyDataEvent();

  @override
  List<Object> get props => [];
}

/// An event to load the additional monthly data.
class LoadMonthlyData extends MonthlyDataEvent {
  /// The month to load data for.
  final int month;
  /// The year to load data for.
  final int year;

  /// Creates a [LoadMonthlyData] event.
  const LoadMonthlyData(this.month, this.year);

  @override
  List<Object> get props => [month, year];
}

/// An event to update the number of non-billable calls.
class UpdateNonBillableCalls extends MonthlyDataEvent {
  /// The month to update data for.
  final int month;
  /// The year to update data for.
  final int year;
  /// The new number of non-billable calls.
  final int nonBillableCalls;

  /// Creates an [UpdateNonBillableCalls] event.
  const UpdateNonBillableCalls(this.month, this.year, this.nonBillableCalls);

  @override
  List<Object> get props => [month, year, nonBillableCalls];
}
