import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';

abstract class ForecasterEvent extends Equatable {
  const ForecasterEvent();

  @override
  List<Object> get props => [];
}

class InitializeForecaster extends ForecasterEvent {
  final MonthlySummary currentSummary;

  const InitializeForecaster({required this.currentSummary});

  @override
  List<Object> get props => [currentSummary];
}

class ProjectedValuesChanged extends ForecasterEvent {
  final double? dailyCalls;
  final double? dailyHours;

  const ProjectedValuesChanged({this.dailyCalls, this.dailyHours});

  @override
  List<Object> get props => [];
}

class SimulateDayOff extends ForecasterEvent {
  final DateTime date;

  const SimulateDayOff({required this.date});

  @override
  List<Object> get props => [date];
}

class ResetSimulation extends ForecasterEvent {}
