import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for backing up the application's database.
///
/// This class encapsulates the business logic for creating a backup of the
/// database. It interacts with the [PerformanceRepository] to perform the backup.
class BackupDatabaseUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [BackupDatabaseUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for the backup operation.
  BackupDatabaseUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Returns a [Future] that completes with the path to the backup file.
  Future<String> execute() {
    return repository.backupDatabase();
  }
}
