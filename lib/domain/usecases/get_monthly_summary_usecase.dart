import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class GetMonthlySummaryUseCase {
  final PerformanceRepository repository;
  
  GetMonthlySummaryUseCase(this.repository);
  
  Future<MonthlySummary> execute(int month, int year) {
    return repository.getMonthlySummary(month, year);
  }
}

