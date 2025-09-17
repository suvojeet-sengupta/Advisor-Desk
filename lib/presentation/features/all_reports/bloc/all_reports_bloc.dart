import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/generate_pdf_report_usecase.dart'; 
import 'package:advisor_desk/domain/usecases/get_all_monthly_summaries_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'all_reports_event.dart';
import 'all_reports_state.dart';

/// A BLoC that manages the state for the "All Reports" feature.
///
/// It handles loading all monthly summaries and exporting them as PDF reports.
class AllReportsBloc extends Bloc<AllReportsEvent, AllReportsState> {
  /// The performance repository for data operations.
  final PerformanceRepository repository;
  late final GetAllMonthlySummariesUseCase _getAllMonthlySummariesUseCase;
  late final GeneratePdfReportUseCase _generatePdfReportUseCase; 

  /// Creates a new instance of [AllReportsBloc].
  AllReportsBloc({required this.repository}) : super(const AllReportsState()) {
    _getAllMonthlySummariesUseCase = GetAllMonthlySummariesUseCase(repository);
    _generatePdfReportUseCase = GeneratePdfReportUseCase(repository);

    on<LoadAllMonthlySummaries>(_onLoadAllMonthlySummaries);
    on<ExportMonthlyReportAsPdf>(_onExportMonthlyReportAsPdf);
  }

  /// Handles the loading of all monthly summaries.
  Future<void> _onLoadAllMonthlySummaries(
    LoadAllMonthlySummaries event,
    Emitter<AllReportsState> emit,
  ) async {
    emit(state.copyWith(status: AllReportsStatus.loading));
    try {
      final summaries = await _getAllMonthlySummariesUseCase.execute();
      emit(state.copyWith(
        status: AllReportsStatus.loaded,
        summaries: summaries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AllReportsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handles the exporting of a monthly report as a PDF.
  ///
  /// Note: The actual PDF generation is handled in the UI layer.
  Future<void> _onExportMonthlyReportAsPdf(
    ExportMonthlyReportAsPdf event,
    Emitter<AllReportsState> emit,
  ) async {
    // This is handled in the UI
  }
}
