import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';

abstract class MonthlyDataState extends Equatable {
  const MonthlyDataState();

  @override
  List<Object> get props => [];
}

class MonthlyDataInitial extends MonthlyDataState {}

class MonthlyDataLoading extends MonthlyDataState {}

class MonthlyDataLoaded extends MonthlyDataState {
  final MonthlyData monthlyData;

  const MonthlyDataLoaded(this.monthlyData);

  @override
  List<Object> get props => [monthlyData];
}

class MonthlyDataError extends MonthlyDataState {
  final String message;

  const MonthlyDataError(this.message);

  @override
  List<Object> get props => [message];
}
