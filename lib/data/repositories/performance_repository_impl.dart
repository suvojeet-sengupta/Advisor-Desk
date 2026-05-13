import 'dart:io';
import 'package:flutter/foundation.dart'; // For compute
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
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:archive/archive_io.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/data/datasources/user_data_source.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';

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
  Future<MonthlySummary> getMonthlySummary(int month, int year) async {
    final totals = await localDataSource.getMonthlyTotals(month, year);
    
    final entries = await localDataSource.getEntriesForMonth(month, year);
    final csatEntries = await localDataSource.getCSATEntriesForMonth(month, year);
    final cqEntries = await localDataSource.getCQEntriesForMonth(month, year);
    final monthlyData = await localDataSource.getMonthlyData(month, year);

    // Use values from SQL aggregation
    double baseSalary = (totals['base_salary'] as num?)?.toDouble() ?? 0.0;

    return MonthlySummary(
      month: month,
      year: year,
      entries: entries,
      csatSummary: CSATSummary(entries: csatEntries, month: month, year: year),
      cqSummary: CQSummary(entries: cqEntries, month: month, year: year),
      loginDays: (totals['count'] as int?) ?? 0,
      nonBillableCalls: monthlyData?.nonBillableCalls ?? 0,
      baseSalary: baseSalary,
    );
  }

  @override
  Future<List<MonthlySummary>> getAllMonthlySummaries({int limit = 10, int offset = 0}) async {
    final monthYearCombinations = await localDataSource.getUniqueMonthYearCombinations(
      limit: limit,
      offset: offset,
    );

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
  Future<ReportSummary> getReportSummary(DateTime startDate, DateTime endDate) async {
    final entries = await localDataSource.getEntriesForDateRange(startDate, endDate);
    final csatEntries = await localDataSource.getCSATEntriesForDateRange(startDate, endDate);
    final cqEntries = await localDataSource.getCQEntriesForDateRange(startDate, endDate);

    // Calculate base salary with custom rate logic
    double baseSalary = 0;
    for (final entry in entries) {
      final rate = entry.customCallRate ?? AppConstants.baseRatePerCall;
      baseSalary += entry.callCount * rate;
    }

    return ReportSummary(
      startDate: startDate,
      endDate: endDate,
      entries: entries,
      csatSummary: CSATSummary(entries: csatEntries, month: startDate.month, year: startDate.year), // Month and year might not be accurate for range, but needed for CSATSummary constructor
      cqSummary: CQSummary(entries: cqEntries, month: startDate.month, year: startDate.year), // Month and year might not be accurate for range, but needed for CQSummary constructor
      baseSalary: baseSalary,
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
      return await localDataSource.updateCSATEntry(entry);
    }
  }

  @override
  Future<int> deleteCSATEntry(int id) async {
    return await localDataSource.deleteCSATEntry(id);
  }

  @override
  Future<int> deleteCSATEntriesByDate(DateTime date) async {
     return await localDataSource.deleteCSATEntriesByDate(date);
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
  Future<void> saveMonthlyData(MonthlyData monthlyData) async {
    await localDataSource.saveMonthlyData(monthlyData);
  }

  @override
  Future<MonthlyData?> getMonthlyData(int month, int year) async {
    return await localDataSource.getMonthlyData(month, year);
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
  Future<List<int>> generateReportPdf(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) async {
    // PdfService already handles isolate/compute internally
    return await _pdfService.generateReportPdf(summary, sectionsToInclude, profile);
  }

  @override
  Future<File> generateReportExcel(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) async {
    return await compute(_generateExcelIsolate, _ReportData(summary, sectionsToInclude, profile));
  }

  @override
  Future<String> backupDatabase() async {
    final dbPath = await localDataSource.getDatabasePath();
    final dbFile = File(dbPath);
    final tempDir = await getTemporaryDirectory();
    final backupPath = '${tempDir.path}/advisor_desk_backup_${DateTime.now().millisecondsSinceEpoch}.zip';

    final encoder = ZipFileEncoder();
    encoder.create(backupPath);
    encoder.addFile(dbFile);
    encoder.close();

    return backupPath;
  }

  @override
  Future<void> restoreDatabase(String backupFilePath) async {
    // Capture the current user id BEFORE closing the db so we re-open the
    // same per-user database, not the default one.
    final currentUserId = await UserDataSource().getCurrentUserId();

    final dbPath = await localDataSource.getDatabasePath();
    final dbFile = File(dbPath);

    InputFileStream? inputStream;
    try {
      inputStream = InputFileStream(backupFilePath);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      if (archive.files.isEmpty) {
        throw Exception("Invalid backup file: archive is empty.");
      }

      // Pick the .db file explicitly instead of blindly using files.first,
      // which can corrupt the database if zip ordering changes.
      final backupDbFile = archive.files.firstWhere(
        (f) => f.isFile && f.name.toLowerCase().endsWith('.db'),
        orElse: () => throw Exception(
          "Invalid backup file: no .db entry found.",
        ),
      );

      final content = backupDbFile.content;
      if (content is! List<int>) {
        throw Exception("Invalid backup file: unreadable db contents.");
      }

      // Close the database before overwriting the file on disk.
      await localDataSource.closeDatabase();

      dbFile.writeAsBytesSync(content);

      // Re-initialize the database for the same user the app was using.
      await LocalDataSource.init(userId: currentUserId);
    } catch (e) {
      // Make sure we leave the database in a usable state even if restore
      // failed mid-way (e.g. corrupt zip, write error).
      try {
        await LocalDataSource.init(userId: currentUserId);
      } catch (_) {
        // Swallow re-init failure; surface the original error below.
      }
      throw Exception('Restore failed: $e');
    } finally {
      await inputStream?.close();
    }
  }

  @override
  Future<int> insertChatMessage(AiInsight message, bool isUser) async {
    return await localDataSource.insertChatMessage(message, isUser);
  }

  @override
  Future<List<AiInsight>> getChatHistory() async {
    return await localDataSource.getChatHistory();
  }

  @override
  Future<void> deleteChatMessage(String id) async {
    try {
      final intId = int.parse(id);
      await localDataSource.deleteChatMessage(intId);
    } catch (e) {
      // If ID is not an int (e.g. temporary timestamp string), just ignore or log
      print("Cannot delete message with ID $id from DB: $e");
    }
  }

  @override
  Future<void> deleteOldChatMessages() async {
    await localDataSource.deleteOldChatMessages();
  }

  @override
  Future<void> clearChatHistory() async {
    await localDataSource.clearChatHistory();
  }
}

// Helper class to pass data to isolates
class _ReportData {
  final ReportSummary summary;
  final List<ReportSection> sectionsToInclude;
  final Profile profile;

  _ReportData(this.summary, this.sectionsToInclude, this.profile);
}

// Top-level function for Excel generation isolate
Future<File> _generateExcelIsolate(_ReportData data) async {
  final excelService = ExcelService();
  return await excelService.generateReportExcel(data.summary, data.sectionsToInclude, data.profile);
}