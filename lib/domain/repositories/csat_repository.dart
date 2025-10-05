import 'package:advisor_desk/domain/entities/csat_entry.dart';

abstract class CSATRepository {
  Future<List<CSATEntry>> getCSATEntriesForDateRange(DateTime startDate, DateTime endDate);
  Future<List<CSATEntry>> getCSATEntriesForMonth(int month, int year);
}