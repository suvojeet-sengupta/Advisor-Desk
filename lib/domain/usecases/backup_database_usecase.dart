import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class BackupDatabaseUseCase {
  final PerformanceRepository repository;

  BackupDatabaseUseCase(this.repository);

  Future<String> execute() {
    return repository.backupDatabase();
  }
}
