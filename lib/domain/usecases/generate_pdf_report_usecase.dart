import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

/// A use case for generating a PDF report.
///
/// This class encapsulates the business logic for creating a PDF file
/// from a [ReportSummary]. It interacts with the [PerformanceRepository]
/// to generate the file.
class GeneratePdfReportUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [GeneratePdfReportUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for report generation.
  GeneratePdfReportUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [summary] contains the data for the report.
  /// The [sectionsToInclude] specifies which sections to include in the report.
  /// The [profile] contains user information to be included in the report.
  ///
  /// Returns a [Future] that completes with a `List<int>` representing the PDF file bytes.
  Future<List<int>> execute(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) {
    return repository.generateReportPdf(summary, sectionsToInclude, profile);
  }
}
