import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  
  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final int month;
  final int year;
  
  const LoadDashboardData({
    required this.month,
    required this.year,
  });
  
  @override
  List<Object> get props => [month, year];
}

class RefreshDashboard extends DashboardEvent {}

class NavigateToAddEntry extends DashboardEvent {}

class NavigateToMonthlyPerformance extends DashboardEvent {}

class NavigateToAllReports extends DashboardEvent {}

