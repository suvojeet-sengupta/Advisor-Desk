import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class GetDailyEntriesUseCase {
  final PerformanceRepository repository;
  
  GetDailyEntriesUseCase(this.repository);
  
  Future<List<DailyEntry>> execute(int month, int year) {
    return repository.getEntriesForMonth(month, year);
  }
}

