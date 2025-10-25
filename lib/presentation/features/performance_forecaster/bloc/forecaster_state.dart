import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/report_summary.dart';

enum ForecasterStatus { initial, loading, loaded, error }

class ForecasterState extends Equatable {
  final ForecasterStatus status;
  final ReportSummary? currentSummary;
  final ReportSummary? projectedSummary;
  final double projectedDailyCalls;
  final double projectedDailyHours;
  final int remainingWorkDays;
  final String? errorMessage;

  const ForecasterState({
    this.status = ForecasterStatus.initial,
    this.currentSummary,
    this.projectedSummary,
    this.projectedDailyCalls = 0,
    this.projectedDailyHours = 0,
    this.remainingWorkDays = 0,
    this.errorMessage,
  });

  ForecasterState copyWith({
    ForecasterStatus? status,
    ReportSummary? currentSummary,
    ReportSummary? projectedSummary,
    double? projectedDailyCalls,
    double? projectedDailyHours,
    int? remainingWorkDays,
    String? errorMessage,
  }) {
    return ForecasterState(
      status: status ?? this.status,
      currentSummary: currentSummary ?? this.currentSummary,
      projectedSummary: projectedSummary ?? this.projectedSummary,
      projectedDailyCalls: projectedDailyCalls ?? this.projectedDailyCalls,
      projectedDailyHours: projectedDailyHours ?? this.projectedDailyHours,
      remainingWorkDays: remainingWorkDays ?? this.remainingWorkDays,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentSummary,
        projectedSummary,
        projectedDailyCalls,
        projectedDailyHours,
        remainingWorkDays,
        errorMessage,
      ];
}
