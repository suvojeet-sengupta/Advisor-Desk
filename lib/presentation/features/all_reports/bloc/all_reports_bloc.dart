import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/generate_pdf_report_usecase.dart'; 
import 'package:advisor_desk/domain/usecases/get_all_monthly_summaries_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'all_reports_event.dart';
import 'all_reports_state.dart';

class AllReportsBloc extends Bloc<AllReportsEvent, AllReportsState> {
  final PerformanceRepository repository;
  late final GetAllMonthlySummariesUseCase _getAllMonthlySummariesUseCase;
  late final GeneratePdfReportUseCase _generatePdfReportUseCase; 

  AllReportsBloc({required this.repository}) : super(const AllReportsState()) {
    _getAllMonthlySummariesUseCase = GetAllMonthlySummariesUseCase(repository);
    _generatePdfReportUseCase = GeneratePdfReportUseCase(repository);

    on<LoadAllMonthlySummaries>(_onLoadAllMonthlySummaries);
    on<LoadMoreMonthlySummaries>(_onLoadMoreMonthlySummaries);
    on<ExportMonthlyReportAsPdf>(_onExportMonthlyReportAsPdf);
  }

  Future<void> _onLoadAllMonthlySummaries(
    LoadAllMonthlySummaries event,
    Emitter<AllReportsState> emit,
  ) async {
    emit(state.copyWith(status: AllReportsStatus.loading));
    try {
      final summaries = await _getAllMonthlySummariesUseCase.execute(limit: 10, offset: 0);
      emit(state.copyWith(
        status: AllReportsStatus.loaded,
        summaries: summaries,
        hasReachedMax: summaries.length < 10,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AllReportsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreMonthlySummaries(
    LoadMoreMonthlySummaries event,
    Emitter<AllReportsState> emit,
  ) async {
    if (state.hasReachedMax || state.status == AllReportsStatus.loading) return;

    emit(state.copyWith(status: AllReportsStatus.loading));

    try {
      final currentSummaries = state.summaries;
      final newSummaries = await _getAllMonthlySummariesUseCase.execute(
        limit: 10,
        offset: currentSummaries.length,
      );

      if (newSummaries.isEmpty) {
        emit(state.copyWith(
          status: AllReportsStatus.loaded,
          hasReachedMax: true,
        ));
      } else {
        emit(state.copyWith(
          status: AllReportsStatus.loaded,
          summaries: List.of(currentSummaries)..addAll(newSummaries),
          hasReachedMax: newSummaries.length < 10,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AllReportsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onExportMonthlyReportAsPdf(
    ExportMonthlyReportAsPdf event,
    Emitter<AllReportsState> emit,
  ) async {
    // This is handled in the UI
  }
}
