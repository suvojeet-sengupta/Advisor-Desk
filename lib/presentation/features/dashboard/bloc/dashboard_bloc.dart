import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:advisor_desk/domain/usecases/check_wrapped_availability_usecase.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_state.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final PerformanceRepository repository;
  late final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;
  late final CheckWrappedAvailabilityUseCase _checkWrappedAvailabilityUseCase;

  // महीने के डेटा को याद रखने के लिए कैश
  final Map<String, MonthlySummary> _summaryCache = {};
  final Map<String, CSATSummary> _csatSummaryCache = {};
  final Map<String, CQSummary> _cqSummaryCache = {};

  DashboardBloc({required this.repository}) : super(DashboardState.initial()) {
    _getMonthlySummaryUseCase = GetMonthlySummaryUseCase(repository);
    _checkWrappedAvailabilityUseCase = CheckWrappedAvailabilityUseCase(repository);
    
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<CheckWrapped>(_onCheckWrapped);
  }

  Future<void> _onCheckWrapped(CheckWrapped event, Emitter<DashboardState> emit) async {
    final wrappedSummary = await _checkWrappedAvailabilityUseCase.execute();
    if (wrappedSummary != null) {
      emit(state.copyWith(wrappedSummary: wrappedSummary));
    }
  }

  Future<void> markWrappedAsSeen() async {
    // This is a helper method to be called from UI when wrapped is closed/viewed
    if (state.wrappedSummary != null) {
      await _checkWrappedAvailabilityUseCase.markAsSeen(
        state.wrappedSummary!.month, 
        state.wrappedSummary!.year
      );
      // We don't emit a new state here to avoid rebuild loops, usually UI just closes
    }
  }
  
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final cacheKey = '${event.year}-${event.month}';

    // अगर डेटा पहले से कैश में है, तो उसे तुरंत दिखाएं
    if (_summaryCache.containsKey(cacheKey) && _csatSummaryCache.containsKey(cacheKey) && _cqSummaryCache.containsKey(cacheKey)) {
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        monthlySummary: _summaryCache[cacheKey],
        csatSummary: _csatSummaryCache[cacheKey],
        cqSummary: _cqSummaryCache[cacheKey],
        currentMonth: event.month,
        currentYear: event.year,
      ));
      return;
    }
    
    // वर्ना, लोडिंग स्टेट दिखाएं और डेटा लाएं
    emit(state.copyWith(
      status: DashboardStatus.loading,
      currentMonth: event.month,
      currentYear: event.year,
    ));
    
    await _fetchAndEmit(event.month, event.year, emit);
  }

  Future<void> _fetchAndEmit(int month, int year, Emitter<DashboardState> emit) async {
    try {
      final monthlySummary = await _getMonthlySummaryUseCase.execute(month, year);
      final csatSummary = await repository.getCSATSummary(month, year);
      final cqSummary = await repository.getCQSummary(month, year);
      
      final cacheKey = '$year-$month';
      _summaryCache[cacheKey] = monthlySummary; // नए डेटा को कैश में सेव करें
      _csatSummaryCache[cacheKey] = csatSummary; 
      _cqSummaryCache[cacheKey] = cqSummary;

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        monthlySummary: monthlySummary,
        csatSummary: csatSummary,
        cqSummary: cqSummary,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // कैश को क्लियर करें ताकि ताजा डेटा आए
    final cacheKey = '${state.currentYear}-${state.currentMonth}';
    _summaryCache.remove(cacheKey);
    _csatSummaryCache.remove(cacheKey); 
    _cqSummaryCache.remove(cacheKey);
    add(LoadDashboardData(
      month: state.currentMonth,
      year: state.currentYear,
    ));
  }
}


