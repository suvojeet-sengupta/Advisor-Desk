import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class GetMonthlyDataUseCase {
  final PerformanceRepository repository;

  GetMonthlyDataUseCase(this.repository);

  Future<MonthlyData?> execute(int month, int year) {
    return repository.getMonthlyData(month, year);
  }
}
