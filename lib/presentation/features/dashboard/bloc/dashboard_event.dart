import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';

/// The base class for all events related to the dashboard.
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  
  @override
  List<Object> get props => [];
}

/// An event to load the dashboard data for a specific month and year.
class LoadDashboardData extends DashboardEvent {
  /// The month to load data for.
  final int month;
  /// The year to load data for.
  final int year;
  
  /// Creates a [LoadDashboardData] event.
  const LoadDashboardData({
    required this.month,
    required this.year,
  });
  
  @override
  List<Object> get props => [month, year];
}

/// An event to refresh the dashboard data.
class RefreshDashboard extends DashboardEvent {}

/// An event to navigate to the "Add Entry" screen.
class NavigateToAddEntry extends DashboardEvent {}

/// An event to navigate to the "Monthly Performance" screen.
class NavigateToMonthlyPerformance extends DashboardEvent {}

/// An event to navigate to the "All Reports" screen.
class NavigateToAllReports extends DashboardEvent {}
