import 'package:advisor_desk/domain/repositories/performance_repository.dart';

/// A use case for restoring the application's database from a backup.
///
/// This class encapsulates the business logic for restoring the database.
/// It interacts with the [PerformanceRepository] to perform the restore.
class RestoreDatabaseUseCase {
  /// The performance repository.
  final PerformanceRepository repository;

  /// Creates a new instance of [RestoreDatabaseUseCase].
  ///
  /// The [repository] is the [PerformanceRepository] to be used for the restore operation.
  RestoreDatabaseUseCase(this.repository);

  /// Executes the use case.
  ///
  /// The [path] is the file path of the backup to restore from.
  Future<void> execute(String path) {
    return repository.restoreDatabase(path);
  }
}
