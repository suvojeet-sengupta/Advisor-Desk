import 'dart:io';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

/// A use case for generating an Excel report.
///
/// This class encapsulates the business logic for creating an Excel file
/// from a [ReportSummary]. It interacts with the [PerformanceRepository]
/// to generate the file.
class GenerateExcelReportUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [GenerateExcelReportUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for report generation.
  GenerateExcelReportUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [summary] contains the data for the report.
  /// The [sectionsToInclude] specifies which sections to include in the report.
  /// The [profile] contains user information to be included in the report.
  ///
  /// Returns a [Future] that completes with the generated [File].
  Future<File> execute(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) {
    return repository.generateReportExcel(summary, sectionsToInclude, profile);
  }
}
