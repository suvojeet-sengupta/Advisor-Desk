import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class DeleteCQEntriesByDateUseCase {
  final PerformanceRepository repository;

  DeleteCQEntriesByDateUseCase(this.repository);

  Future<int> execute(DateTime date) {
    return repository.deleteCQEntriesByDate(date);
  }
}
