import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class DeleteEntryUseCase {
  final PerformanceRepository repository;
  
  DeleteEntryUseCase(this.repository);
  
  Future<int> execute(int id) {
    return repository.deleteEntry(id);
  }
}

