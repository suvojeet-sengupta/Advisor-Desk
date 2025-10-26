import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'forecaster_event.dart';
import 'forecaster_state.dart';

class ForecasterBloc extends Bloc<ForecasterEvent, ForecasterState> {
  final LeaveRepository leaveRepository;

  ForecasterBloc({required this.leaveRepository}) : super(const ForecasterState()) {
    on<InitializeForecaster>(_onInitializeForecaster);
    on<ProjectedValuesChanged>(_onProjectedValuesChanged);
    on<SimulateDayOff>(_onSimulateDayOff);
    on<ResetSimulation>(_onResetSimulation);
  }

  void _onInitializeForecaster(
    InitializeForecaster event,
    Emitter<ForecasterState> emit,
  ) async {
    emit(state.copyWith(status: ForecasterStatus.loading));

    final now = DateTime.now();
    final currentMonth = event.currentSummary.month;
    final currentYear = event.currentSummary.year;

    // Use ReportSummary for consistent calculations
    final baseSummary = ReportSummary(
      startDate: DateTime(currentYear, currentMonth, 1),
      endDate: DateTime(currentYear, currentMonth + 1, 0),
      entries: event.currentSummary.entries,
      csatSummary: event.currentSummary.csatSummary,
      cqSummary: event.currentSummary.cqSummary,
      baseSalary: event.currentSummary.baseSalary,
    );

    int remainingDays = await _getRemainingWorkDays(currentYear, currentMonth);

    final avgCalls = remainingDays > 0 && baseSummary.entries.isNotEmpty ? baseSummary.totalCalls / baseSummary.entries.length : 0.0;
    final avgHours = remainingDays > 0 && baseSummary.entries.isNotEmpty ? baseSummary.totalLoginHours / baseSummary.entries.length : 0.0;

    emit(state.copyWith(
      status: ForecasterStatus.loaded,
      currentSummary: baseSummary,
      projectedSummary: baseSummary, // Initially, projected is same as current
      remainingWorkDays: remainingDays,
      projectedDailyCalls: 0.0,
      projectedDailyHours: 0.0,
    ));
  }

  void _onProjectedValuesChanged(
    ProjectedValuesChanged event,
    Emitter<ForecasterState> emit,
  ) {
    if (state.status != ForecasterStatus.loaded) return;

    final newDailyCalls = event.dailyCalls ?? state.projectedDailyCalls;
    final newDailyHours = event.dailyHours ?? state.projectedDailyHours;

    final projectedSummary = _calculateProjection(
      baseSummary: state.currentSummary!,
      remainingDays: state.remainingWorkDays,
      dailyCalls: newDailyCalls,
      dailyHours: newDailyHours,
    );

    emit(state.copyWith(
      projectedSummary: projectedSummary,
      projectedDailyCalls: newDailyCalls,
      projectedDailyHours: newDailyHours,
    ));
  }

  void _onSimulateDayOff(
    SimulateDayOff event,
    Emitter<ForecasterState> emit,
  ) {
     if (state.status != ForecasterStatus.loaded) return;

    final remainingDays = state.remainingWorkDays - 1;

    final projectedSummary = _calculateProjection(
      baseSummary: state.currentSummary!,
      remainingDays: remainingDays.clamp(0, 31),
      dailyCalls: state.projectedDailyCalls,
      dailyHours: state.projectedDailyHours,
    );

    emit(state.copyWith(
      projectedSummary: projectedSummary,
      remainingWorkDays: remainingDays.clamp(0, 31),
    ));
  }

  void _onResetSimulation(
    ResetSimulation event,
    Emitter<ForecasterState> emit,
  ) async {
     if (state.status != ForecasterStatus.loaded) return;

    final remainingDays = await _getRemainingWorkDays(state.currentSummary!.startDate.year, state.currentSummary!.startDate.month);

    emit(state.copyWith(
      projectedSummary: state.currentSummary,
      remainingWorkDays: remainingDays,
      projectedDailyCalls: 0.0,
      projectedDailyHours: 0.0,
    ));
  }

  ReportSummary _calculateProjection({
    required ReportSummary baseSummary,
    required int remainingDays,
    required double dailyCalls,
    required double dailyHours,
  }) {
    final projectedCalls = (dailyCalls * remainingDays).round();
    final projectedHours = dailyHours * remainingDays;

    final totalProjectedCalls = baseSummary.totalCalls + projectedCalls;
    final totalProjectedHours = baseSummary.totalLoginHours + projectedHours;

    // Create a new list of entries for projection
    // This is a simplified model for calculation purposes
    final List<DailyEntry> projectedEntries = [
      ...baseSummary.entries,
      // Add a dummy entry representing the total projected work
      DailyEntry(
        date: DateTime.now(),
        loginHours: (projectedHours).floor(),
        loginMinutes: ((projectedHours - projectedHours.floor()) * 60).round(),
        loginSeconds: 0,
        callCount: projectedCalls,
      )
    ];

    // Recalculate base salary for the projected total calls
    final newBaseSalary = totalProjectedCalls * AppConstants.baseRatePerCall; // Use constant for projection

    return ReportSummary(
      startDate: baseSummary.startDate,
      endDate: baseSummary.endDate,
      entries: projectedEntries,
      csatSummary: baseSummary.csatSummary,
      cqSummary: baseSummary.cqSummary,
      baseSalary: newBaseSalary,
    );
  }

  Future<int> _getRemainingWorkDays(int year, int month) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // If we are forecasting for a future or past month, consider all days
    if (year != now.year || month != now.month) {
      return 0; // Or handle as per business logic for past/future months
    }

    final leaveEntries = await leaveRepository.getLeaveEntriesForMonth(year, month);
    final leaveDates = leaveEntries.map((e) => e.date).toSet();

    int remainingDays = 0;
    for (int i = today.day; i <= lastDayOfMonth.day; i++) {
      final date = DateTime(year, month, i);
      // A day is a workday if it's not a weekend (Sat/Sun) and not marked as leave
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        if (!leaveDates.contains(date)) {
          remainingDays++;
        }
      }
    }
    return remainingDays;
  }
}
