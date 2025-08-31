import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class SaveMonthlyDataUseCase {
  final PerformanceRepository repository;

  SaveMonthlyDataUseCase(this.repository);

  Future<void> execute(MonthlyData monthlyData) {
    return repository.saveMonthlyData(monthlyData);
  }
}
