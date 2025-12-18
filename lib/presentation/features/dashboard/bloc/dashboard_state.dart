import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final MonthlySummary? monthlySummary;
  final CSATSummary? csatSummary; 
  final CQSummary? cqSummary;
  final MonthlySummary? wrappedSummary; // Null if no wrapped to show
  final String? errorMessage;
  final int currentMonth;
  final int currentYear;
  
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.monthlySummary,
    this.csatSummary,
    this.cqSummary,
    this.wrappedSummary,
    this.errorMessage,
    required this.currentMonth,
    required this.currentYear,
  });
  
  factory DashboardState.initial() {
    final now = DateTime.now();
    return DashboardState(
      status: DashboardStatus.initial,
      currentMonth: now.month,
      currentYear: now.year,
    );
  }
  
  DashboardState copyWith({
    DashboardStatus? status,
    MonthlySummary? monthlySummary,
    CSATSummary? csatSummary,
    CQSummary? cqSummary,
    MonthlySummary? wrappedSummary,
    String? errorMessage,
    int? currentMonth,
    int? currentYear,
  }) {
    return DashboardState(
      status: status ?? this.status,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      csatSummary: csatSummary ?? this.csatSummary,
      cqSummary: cqSummary ?? this.cqSummary,
      wrappedSummary: wrappedSummary ?? this.wrappedSummary, // Explicitly pass null if needed
      errorMessage: errorMessage,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
    );
  }
  
  // Note: wrappedSummary is usually one-off, but including it in props for correctness
  @override
  List<Object?> get props => [status, monthlySummary, csatSummary, cqSummary, wrappedSummary, errorMessage, currentMonth, currentYear];
}


