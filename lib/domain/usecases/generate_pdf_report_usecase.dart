import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class GeneratePdfReportUseCase {
  final PerformanceRepository repository;

  GeneratePdfReportUseCase(this.repository);

  Future<List<int>> execute(MonthlySummary summary) {
    return repository.generateMonthlyReportPdf(summary);
  }
}

