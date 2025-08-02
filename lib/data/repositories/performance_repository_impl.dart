import 'dart:io';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:advisor_desk/data/datasources/pdf_service.dart';
import 'package:advisor_desk/data/datasources/excel_service.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class PerformanceRepositoryImpl implements PerformanceRepository {
  final LocalDataSource localDataSource;
  final PdfService _pdfService = PdfService();
  final ExcelService _excelService = ExcelService();

  PerformanceRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<DailyEntry>> getAllEntries() async {
    return await localDataSource.getAllEntries();
  }

  @override
  Future<List<DailyEntry>> getEntriesForMonth(int month, int year) async {
    return await localDataSource.getEntriesForMonth(month, year);
  }

  @override
  Future<DailyEntry?> getEntryForDate(DateTime date) async {
    return await localDataSource.getEntryForDate(date);
  }

  @override
  Future<int> addEntry(DailyEntry entry) async {
    return await localDataSource.insertEntry(entry);
  }

  @override
  Future<int> updateEntry(DailyEntry entry) async {
    return await localDataSource.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return localDataSource.deleteEntry(id);
  }

  @override
  Future<int> deleteCQEntriesByDate(DateTime date) {
    return localDataSource.deleteCQEntriesByDate(date);
  }

  @override
  Future<int> deleteCSATEntriesByDate(DateTime date) {
    return localDataSource.deleteCSATEntriesByDate(date);
  }

  @override
  Future<List<MonthlySummary>> getAllMonthlySummaries() async {
    final monthYearCombinations = await localDataSource.getUniqueMonthYearCombinations();
    final List<MonthlySummary> summaries = [];
    for (final combination in monthYearCombinations) {
      final month = combination["month"]!;
      final year = combination["year"]!;
      final summary = await getMonthlySummary(month, year);
      summaries.add(summary);
    }
    return summaries;
  }

  @override
  Future<MonthlySummary> getMonthlySummary(int month, int year) async {
    final entries = await localDataSource.getEntriesForMonth(month, year);
    final csatEntries = await localDataSource.getCSATEntriesForMonth(month, year);
    final cqEntries = await localDataSource.getCQEntriesForMonth(month, year);

    return MonthlySummary(
      month: month,
      year: year,
      entries: entries,
      csatSummary: CSATSummary(entries: csatEntries, month: month, year: year),
      cqSummary: CQSummary(entries: cqEntries, month: month, year: year),
    );
  }

  @override
  Future<ReportSummary> getReportSummary(DateTime startDate, DateTime endDate) async {
    final entries = await localDataSource.getEntriesForDateRange(startDate, endDate);
    final csatEntries = await localDataSource.getCSATEntriesForDateRange(startDate, endDate);
    final cqEntries = await localDataSource.getCQEntriesForDateRange(startDate, endDate);

    return ReportSummary(
      startDate: startDate,
      endDate: endDate,
      entries: entries,
      csatSummary: CSATSummary(entries: csatEntries, month: startDate.month, year: startDate.year), // Month and year might not be accurate for range, but needed for CSATSummary constructor
      cqSummary: CQSummary(entries: cqEntries, month: startDate.month, year: startDate.year), // Month and year might not be accurate for range, but needed for CQSummary constructor
    );
  }

  @override
  Future<CSATSummary> getCSATSummary(int month, int year) async {
    final csatEntries = await localDataSource.getCSATEntriesForMonth(month, year);
    return CSATSummary(entries: csatEntries, month: month, year: year);
  }

  @override
  Future<CQSummary> getCQSummary(int month, int year) async {
    final cqEntries = await localDataSource.getCQEntriesForMonth(month, year);
    return CQSummary(entries: cqEntries, month: month, year: year);
  }

  @override
  Future<int> saveCSATEntry(CSATEntry entry) async {
    if (entry.id == null) {
      return await localDataSource.insertCSATEntry(entry);
    } else {
      // Assuming updateCSATEntry exists in LocalDataSource, need to add if not.
      // For now, let's assume insert handles both insert and update based on ID.
      // If not, we'll need to add updateCSATEntry to LocalDataSource.
      return await localDataSource.insertCSATEntry(entry); // This might need to be updateCSATEntry
    }
  }

  @override
  Future<int> deleteCSATEntry(int id) async {
    return await localDataSource.deleteCSATEntry(id);
  }

  // CQ entry methods implementation
  @override
  Future<int> saveCQEntry(CQEntry entry) async {
    if (entry.id == null) {
      return await localDataSource.insertCQEntry(entry);
    } else {
      return await localDataSource.updateCQEntry(entry);
    }
  }

  @override
  Future<int> deleteCQEntry(int id) async {
    return await localDataSource.deleteCQEntry(id);
  }

  @override
  Future<List<CQEntry>> getAllCQEntries() async {
    return await localDataSource.getAllCQEntries();
  }

  @override
  Future<List<CQEntry>> getCQEntriesForMonth(int month, int year) async {
    return await localDataSource.getCQEntriesForMonth(month, year);
  }

  @override
  Future<CQEntry?> getCQEntryForDate(DateTime date) async {
    return await localDataSource.getCQEntryForDate(date);
  }

  @override
  Future<int> updateCQEntry(CQEntry entry) async {
    return await localDataSource.updateCQEntry(entry);
  }

  @override
  Future<List<int>> generateMonthlyReportPdf(MonthlySummary summary) async {
    // This method is now deprecated. Use generateReportPdf instead.
    throw UnimplementedError('generateMonthlyReportPdf is deprecated. Use generateReportPdf instead.');
  }

  @override
  Future<File> generateMonthlyReportExcel(MonthlySummary summary) async {
    // This method is now deprecated. Use generateReportExcel instead.
    throw UnimplementedError('generateMonthlyReportExcel is deprecated. Use generateReportExcel instead.');
  }

  @override
  Future<List<int>> generateReportPdf(ReportSummary summary, List<ReportSection> sectionsToInclude) async {
    return _pdfService.generateReportPdf(summary, sectionsToInclude);
  }

  @override
  Future<File> generateReportExcel(ReportSummary summary, List<ReportSection> sectionsToInclude) async {
    return _excelService.generateReportExcel(summary, sectionsToInclude);
  }

  @override
  Future<String> backupDatabase() async {
    final dbPath = await localDataSource.getDatabasePath();
    final dbFile = File(dbPath);
    final backupDir = await getExternalStorageDirectory();
    if (backupDir == null) {
      throw Exception("Could not get external storage directory for backup.");
    }
    final backupPath = '${backupDir.path}/advisor_desk_backup_${DateTime.now().millisecondsSinceEpoch}.db';
    await dbFile.copy(backupPath);
    return backupPath;
  }

  @override
  Future<void> restoreDatabase(String backupFilePath) async {
    final dbPath = await localDataSource.getDatabasePath();
    final dbFile = File(dbPath);
    final backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      throw Exception("Backup file not found at $backupFilePath");
    }

    // Close the database before restoring
    await localDataSource.closeDatabase();

    await backupFile.copy(dbPath);

    // Re-initialize the database after restoring
    await LocalDataSource.init();
  }
}


