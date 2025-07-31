import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class GeneratePdfReportUseCase {
  final PerformanceRepository repository;

  GeneratePdfReportUseCase(this.repository);

  Future<List<int>> execute(ReportSummary summary, List<ReportSection> sectionsToInclude) {
    return repository.generateReportPdf(summary, sectionsToInclude);
  }
}

