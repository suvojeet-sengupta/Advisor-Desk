import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'dart:io';

/// An abstract repository for managing all performance-related data.
///
/// This class defines the contract for operations related to daily entries,
/// monthly summaries, CSAT, CQ, report generation, and database maintenance.
abstract class PerformanceRepository {
  // Methods for daily entries

  /// Retrieves all daily entries.
  Future<List<DailyEntry>> getAllEntries();

  /// Retrieves all daily entries for a specific [month] and [year].
  Future<List<DailyEntry>> getEntriesForMonth(int month, int year);

  /// Retrieves the daily entry for a specific [date].
  Future<DailyEntry?> getEntryForDate(DateTime date);

  /// Adds a new daily entry.
  Future<int> addEntry(DailyEntry entry);

  /// Updates an existing daily entry.
  Future<int> updateEntry(DailyEntry entry);

  /// Deletes a daily entry by its [id].
  Future<int> deleteEntry(int id);

  /// Deletes all CQ entries for a specific [date].
  Future<int> deleteCQEntriesByDate(DateTime date);

  /// Deletes all CSAT entries for a specific [date].
  Future<int> deleteCSATEntriesByDate(DateTime date);

  // Methods for summaries and reports

  /// Retrieves summaries for all months that have data.
  Future<List<MonthlySummary>> getAllMonthlySummaries();

  /// Retrieves a summary for a specific [month] and [year].
  Future<MonthlySummary> getMonthlySummary(int month, int year);

  /// Retrieves a CSAT summary for a specific [month] and [year].
  Future<CSATSummary> getCSATSummary(int month, int year);

  /// Retrieves a CQ summary for a specific [month] and [year].
  Future<CQSummary> getCQSummary(int month, int year);

  /// Retrieves a report summary for a given date range.
  Future<ReportSummary> getReportSummary(DateTime startDate, DateTime endDate);

  // Methods for CSAT entries

  /// Saves a CSAT entry.
  Future<int> saveCSATEntry(CSATEntry entry);

  /// Deletes a CSAT entry by its [id].
  Future<int> deleteCSATEntry(int id);
  
  // Methods for CQ entries

  /// Saves a CQ entry.
  Future<int> saveCQEntry(CQEntry entry);

  /// Deletes a CQ entry by its [id].
  Future<int> deleteCQEntry(int id);

  /// Retrieves all CQ entries.
  Future<List<CQEntry>> getAllCQEntries();

  /// Retrieves all CQ entries for a specific [month] and [year].
  Future<List<CQEntry>> getCQEntriesForMonth(int month, int year);

  /// Retrieves the CQ entry for a specific [date].
  Future<CQEntry?> getCQEntryForDate(DateTime date);

  /// Updates an existing CQ entry.
  Future<int> updateCQEntry(CQEntry entry);

  // Methods for monthly data

  /// Saves additional monthly data.
  Future<void> saveMonthlyData(MonthlyData monthlyData);

  /// Retrieves additional monthly data for a specific [month] and [year].
  Future<MonthlyData?> getMonthlyData(int month, int year);
  
  // Deprecated methods
  
  @deprecated
  Future<List<int>> generateMonthlyReportPdf(MonthlySummary summary);

  @deprecated
  Future<File> generateMonthlyReportExcel(MonthlySummary summary);

  // Methods for report generation

  /// Generates a PDF report for a given summary and sections.
  Future<List<int>> generateReportPdf(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile);

  /// Generates an Excel report for a given summary and sections.
  Future<File> generateReportExcel(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile);

  // Methods for database backup and restore

  /// Backs up the database to a zip file.
  /// Returns the path to the backup file.
  Future<String> backupDatabase();

  /// Restores the database from a backup file.
  ///
  /// The [backupFilePath] is the path to the zip file.
  Future<void> restoreDatabase(String backupFilePath);
}
