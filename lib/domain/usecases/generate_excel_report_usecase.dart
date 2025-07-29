import 'dart:io';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class GenerateExcelReportUseCase {
  final PerformanceRepository repository;

  GenerateExcelReportUseCase(this.repository);

  Future<File> execute(MonthlySummary summary) {
    return repository.generateMonthlyReportExcel(summary);
  }
}
