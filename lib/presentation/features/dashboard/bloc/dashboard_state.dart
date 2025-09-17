import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

/// The status of the dashboard.
enum DashboardStatus { initial, loading, loaded, error }

/// The state for the dashboard screen.
///
/// This class holds all the data related to the state of the dashboard,
/// including the current status, monthly summary, and any error messages.
class DashboardState extends Equatable {
  /// The current status of the dashboard.
  final DashboardStatus status;
  /// The monthly summary data.
  final MonthlySummary? monthlySummary;
  /// The CSAT summary data.
  final CSATSummary? csatSummary;
  /// The CQ summary data.
  final CQSummary? cqSummary;
  /// An error message, if any.
  final String? errorMessage;
  /// The currently selected month.
  final int currentMonth;
  /// The currently selected year.
  final int currentYear;
  
  /// Creates a new instance of [DashboardState].
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.monthlySummary,
    this.csatSummary,
    this.cqSummary,
    this.errorMessage,
    required this.currentMonth,
    required this.currentYear,
  });
  
  /// Creates an initial state with the current month and year.
  factory DashboardState.initial() {
    final now = DateTime.now();
    return DashboardState(
      status: DashboardStatus.initial,
      currentMonth: now.month,
      currentYear: now.year,
    );
  }
  
  /// Creates a copy of this state but with the given fields replaced with new values.
  DashboardState copyWith({
    DashboardStatus? status,
    MonthlySummary? monthlySummary,
    CSATSummary? csatSummary,
    CQSummary? cqSummary,
    String? errorMessage,
    int? currentMonth,
    int? currentYear,
  }) {
    return DashboardState(
      status: status ?? this.status,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      csatSummary: csatSummary ?? this.csatSummary,
      cqSummary: cqSummary ?? this.cqSummary,
      errorMessage: errorMessage,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
    );
  }
  
  @override
  List<Object?> get props => [status, monthlySummary, csatSummary, cqSummary, errorMessage, currentMonth, currentYear];
}
