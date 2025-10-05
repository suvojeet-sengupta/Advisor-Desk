import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/daily_entry_repository.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';

class DailyEntryRepositoryImpl implements DailyEntryRepository {
  final LocalDataSource localDataSource;

  DailyEntryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DailyEntry>> getAllEntries() {
    return localDataSource.getAllEntries();
  }

  @override
  Future<DailyEntry?> getEntryForDate(DateTime date) {
    return localDataSource.getEntryForDate(date);
  }

  @override
  Future<int> insertEntry(DailyEntry entry) {
    return localDataSource.insertEntry(entry);
  }

  @override
  Future<int> updateEntry(DailyEntry entry) {
    return localDataSource.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return localDataSource.deleteEntry(id);
  }
}