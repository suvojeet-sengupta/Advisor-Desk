import 'dart:io';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class GenerateExcelReportUseCase {
  final PerformanceRepository repository;

  GenerateExcelReportUseCase(this.repository);

  Future<File> execute(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) {
    return repository.generateReportExcel(summary, sectionsToInclude, profile);
  }
}
