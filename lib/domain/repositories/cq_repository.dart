import 'package:advisor_desk/domain/entities/cq_entry.dart';

abstract class CQRepository {
  Future<List<CQEntry>> getCQEntriesForDateRange(DateTime startDate, DateTime endDate);
  Future<List<CQEntry>> getCQEntriesForMonth(int month, int year);
}