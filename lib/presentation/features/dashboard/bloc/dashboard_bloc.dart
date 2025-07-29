import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_state.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final PerformanceRepository repository;
  late final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;

  // महीने के डेटा को याद रखने के लिए कैश
  final Map<String, MonthlySummary> _summaryCache = {};
  final Map<String, CSATSummary> _csatSummaryCache = {}; // New cache for CSATSummary
  final Map<String, CQSummary> _cqSummaryCache = {}; // New cache for CQSummary

  DashboardBloc({required this.repository}) : super(DashboardState.initial()) {
    _getMonthlySummaryUseCase = GetMonthlySummaryUseCase(repository);
    
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
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
        csatSummary: _csatSummaryCache[cacheKey], // Pass CSATSummary from cache
        cqSummary: _cqSummaryCache[cacheKey], // Pass CQSummary from cache
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
      final csatSummary = await repository.getCSATSummary(month, year); // Fetch CSATSummary separately
      final cqSummary = await repository.getCQSummary(month, year); // Fetch CQSummary separately
      
      final cacheKey = '$year-$month';
      _summaryCache[cacheKey] = monthlySummary; // नए डेटा को कैश में सेव करें
      _csatSummaryCache[cacheKey] = csatSummary; // Save CSATSummary to cache
      _cqSummaryCache[cacheKey] = cqSummary; // Save CQSummary to cache

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        monthlySummary: monthlySummary,
        csatSummary: csatSummary, // Pass fetched CSATSummary
        cqSummary: cqSummary, // Pass fetched CQSummary
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
    _csatSummaryCache.remove(cacheKey); // Clear CSATSummary cache
    _cqSummaryCache.remove(cacheKey); // Clear CQSummary cache
    add(LoadDashboardData(
      month: state.currentMonth,
      year: state.currentYear,
    ));
  }
}


