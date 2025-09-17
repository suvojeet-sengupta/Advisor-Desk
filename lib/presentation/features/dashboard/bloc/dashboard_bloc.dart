import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_state.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

/// A BLoC that manages the state for the dashboard screen.
///
/// It handles loading the monthly performance data, including the monthly summary,
/// CSAT summary, and CQ summary. It also caches the data to avoid unnecessary
/// network requests.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// The performance repository for data operations.
  final PerformanceRepository repository;
  late final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;

  // Cache to store the month's data.
  final Map<String, MonthlySummary> _summaryCache = {};
  final Map<String, CSATSummary> _csatSummaryCache = {}; // New cache for CSATSummary
  final Map<String, CQSummary> _cqSummaryCache = {}; // New cache for CQSummary

  /// Creates a new instance of [DashboardBloc].
  DashboardBloc({required this.repository}) : super(DashboardState.initial()) {
    _getMonthlySummaryUseCase = GetMonthlySummaryUseCase(repository);
    
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
  }
  
  /// Handles the loading of the dashboard data for a specific month and year.
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final cacheKey = '${event.year}-${event.month}';

    // If the data is already in the cache, show it immediately.
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
    
    // Otherwise, show the loading state and fetch the data.
    emit(state.copyWith(
      status: DashboardStatus.loading,
      currentMonth: event.month,
      currentYear: event.year,
    ));
    
    await _fetchAndEmit(event.month, event.year, emit);
  }

  /// Fetches the data for a specific month and year and emits the new state.
  Future<void> _fetchAndEmit(int month, int year, Emitter<DashboardState> emit) async {
    try {
      final monthlySummary = await _getMonthlySummaryUseCase.execute(month, year);
      final csatSummary = await repository.getCSATSummary(month, year); // Fetch CSATSummary separately
      final cqSummary = await repository.getCQSummary(month, year); // Fetch CQSummary separately
      
      final cacheKey = '$year-$month';
      _summaryCache[cacheKey] = monthlySummary; // Save the new data to the cache
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
  
  /// Handles the refreshing of the dashboard data.
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Clear the cache to get fresh data.
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
