import 'package:advisor_desk/domain/entities/daily_entry.dart';

abstract class DailyEntryRepository {
  Future<List<DailyEntry>> getAllEntries();
  Future<DailyEntry?> getEntryForDate(DateTime date);
  Future<int> insertEntry(DailyEntry entry);
  Future<int> updateEntry(DailyEntry entry);
  Future<int> deleteEntry(int id);
}