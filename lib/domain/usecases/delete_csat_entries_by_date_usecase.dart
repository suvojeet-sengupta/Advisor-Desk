import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class DeleteCSATEntriesByDateUseCase {
  final PerformanceRepository repository;

  DeleteCSATEntriesByDateUseCase(this.repository);

  Future<int> execute(DateTime date) {
    return repository.deleteCSATEntriesByDate(date);
  }
}
