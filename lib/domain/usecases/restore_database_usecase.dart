import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class RestoreDatabaseUseCase {
  final PerformanceRepository repository;

  RestoreDatabaseUseCase(this.repository);

  Future<void> execute(String path) {
    return repository.restoreDatabase(path);
  }
}
