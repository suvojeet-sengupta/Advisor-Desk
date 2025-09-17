import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';

/// The base class for all states related to additional monthly data.
abstract class MonthlyDataState extends Equatable {
  const MonthlyDataState();

  @override
  List<Object> get props => [];
}

/// The initial state of the additional monthly data feature.
class MonthlyDataInitial extends MonthlyDataState {}

/// The state indicating that the additional monthly data is being loaded.
class MonthlyDataLoading extends MonthlyDataState {}

/// The state indicating that the additional monthly data has been successfully loaded.
class MonthlyDataLoaded extends MonthlyDataState {
  /// The loaded monthly data.
  final MonthlyData monthlyData;

  /// Creates a [MonthlyDataLoaded] state.
  const MonthlyDataLoaded(this.monthlyData);

  @override
  List<Object> get props => [monthlyData];
}

/// The state indicating that an error occurred while loading the additional monthly data.
class MonthlyDataError extends MonthlyDataState {
  /// The error message.
  final String message;

  /// Creates a [MonthlyDataError] state.
  const MonthlyDataError(this.message);

  @override
  List<Object> get props => [message];
}
