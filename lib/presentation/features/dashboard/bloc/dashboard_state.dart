import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final MonthlySummary? monthlySummary;
  final CSATSummary? csatSummary; // Added CSATSummary field
  final CQSummary? cqSummary; // Added CQSummary field
  final String? errorMessage;
  final int currentMonth;
  final int currentYear;
  
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.monthlySummary,
    this.csatSummary, // Added to constructor
    this.cqSummary, // Added to constructor
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
    CSATSummary? csatSummary, // Added to copyWith
    CQSummary? cqSummary, // Added to copyWith
    String? errorMessage,
    int? currentMonth,
    int? currentYear,
  }) {
    return DashboardState(
      status: status ?? this.status,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      csatSummary: csatSummary ?? this.csatSummary, // Added to copyWith logic
      cqSummary: cqSummary ?? this.cqSummary, // Added to copyWith logic
      errorMessage: errorMessage,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
    );
  }
  
  @override
  List<Object?> get props => [status, monthlySummary, csatSummary, cqSummary, errorMessage, currentMonth, currentYear];
}


