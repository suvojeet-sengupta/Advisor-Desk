import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class ExcelService {
  Future<File> generateReportExcel(ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // Add header row
    sheet.appendRow([
      'Advisor Desk Performance Report',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0));
    sheet.appendRow([
      'Advisor: ${profile.name}',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1));
    sheet.appendRow([
      'Period: ${summary.formattedDateRange}',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1));
    sheet.appendRow([]); // Empty row for spacing

    if (sectionsToInclude.contains(ReportSection.monthlySummary)) {
      // Monthly Summary
      sheet.appendRow(['Summary']);
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
      sheet.appendRow(['Description', 'Value']);
      sheet.appendRow([
        'Total Login Hours',
        '${summary.totalLoginHours.toStringAsFixed(2)} hrs'
      ]);
      sheet.appendRow([
        'Total Calls',
        summary.totalCalls.toString()
      ]);
      sheet.appendRow([
        'Average Daily Hours',
        '${summary.averageDailyLoginHours.toStringAsFixed(2)} hrs'
      ]);
      sheet.appendRow([
        'Average Daily Calls',
        summary.averageDailyCalls.toStringAsFixed(2)
      ]);
      sheet.appendRow([]); // Empty row for spacing
    }

    if (sectionsToInclude.contains(ReportSection.csatSummary)) {
      // CSAT Summary
      if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) {
        sheet.appendRow(['Overall CSAT Performance']);
        sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
            CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
        sheet.appendRow(['Description', 'Value']);
        sheet.appendRow([
          'Total T2 Count',
          summary.csatSummary!.totalT2Count.toString()
        ]);
        sheet.appendRow([
          'Total B2 Count',
          summary.csatSummary!.totalB2Count.toString()
        ]);
        sheet.appendRow([
          'Total N Count',
          summary.csatSummary!.totalNCount.toString()
        ]);
        sheet.appendRow([
          'Total Survey Hits',
          summary.csatSummary!.totalSurveyHits.toString()
        ]);
        sheet.appendRow([
          'Monthly CSAT Percentage',
          '${summary.csatSummary!.monthlyCSATPercentage.toStringAsFixed(2)}%'
        ]);
        sheet.appendRow([
          'Average Daily CSAT Score',
          '${summary.csatSummary!.averageScore.toStringAsFixed(2)}%'
        ]);
        sheet.appendRow([]); // Empty row for spacing
      }
    }

    if (sectionsToInclude.contains(ReportSection.cqSummary)) {
      // CQ Summary
      if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) {
        sheet.appendRow(['Overall CQ Performance']);
        sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
            CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
        sheet.appendRow(['Description', 'Value']);
        sheet.appendRow([
          'Total CQ Entries',
          summary.cqSummary!.entries.length.toString()
        ]);
        sheet.appendRow([
          'Average CQ Score',
          summary.cqSummary!.averageScore.toStringAsFixed(2)
        ]);
        sheet.appendRow([]); // Empty row for spacing
      }
    }

    if (sectionsToInclude.contains(ReportSection.salaryDetails)) {
      // Salary Details
      sheet.appendRow(['Salary Details']);
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
      sheet.appendRow(['Description', 'Amount', 'Status']);
      sheet.appendRow([
        'Base Salary',
        'Rs. ${summary.baseSalary.toStringAsFixed(2)}',
        ''
      ]);
      sheet.appendRow([
        'Bonus',
        'Rs. ${summary.bonusAmount.toStringAsFixed(2)}',
        summary.isBonusAchieved ? 'Achieved' : 'Not Achieved'
      ]);
      sheet.appendRow([
        'CSAT Bonus',
        'Rs. ${summary.csatBonus.toStringAsFixed(2)}',
        summary.isCSATBonusAchieved ? 'Achieved' : 'Not Achieved'
      ]);
      sheet.appendRow([
        'Gross Salary',
        'Rs. ${(summary.totalSalary + summary.csatBonus).toStringAsFixed(2)}',
        ''
      ]);
      sheet.appendRow([
        'TDS Deduction (${(summary.tdsDeduction / (summary.totalSalary + summary.csatBonus) * 100).toStringAsFixed(0)}%)',
        'Rs. -${summary.tdsDeduction.toStringAsFixed(2)}'
      ]);
      sheet.appendRow([
        'Net Salary',
        'Rs. ${summary.netSalary.toStringAsFixed(2)}'
      ]);
      sheet.appendRow([]); // Empty row for spacing
    }

    if (sectionsToInclude.contains(ReportSection.dailyEntries)) {
      // Daily Entries
      if (summary.entries.isNotEmpty) {
        sheet.appendRow(['Daily Entries']);
        sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
            CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
        sheet.appendRow(['Date', 'Login Time', 'Call Count']);
        for (var entry in summary.entries) {
          sheet.appendRow([
            DateFormat('dd-MMM-yyyy').format(entry.date),
            entry.formattedLoginTime,
            entry.callCount,
          ]);
        }
        sheet.appendRow([]); // Empty row for spacing
      }
    }

    if (sectionsToInclude.contains(ReportSection.csatDailyBreakdown)) {
      // CSAT Daily Breakdown
      if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) {
        sheet.appendRow(['CSAT Daily Breakdown']);
        sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
            CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
        sheet.appendRow(['Date', 'T2', 'B2', 'N', 'CSAT %']);
        for (var entry in summary.csatSummary!.entries) {
          final total = entry.t2Count + entry.b2Count + entry.nCount;
          final csatPercentage = total == 0 ? 0.0 : ((entry.t2Count - entry.b2Count) / total) * 100;
          sheet.appendRow([
            DateFormat('dd-MMM-yyyy').format(entry.date),
            entry.t2Count,
            entry.b2Count,
            entry.nCount,
            csatPercentage.toStringAsFixed(2) + '%',
          ]);
        }
        sheet.appendRow([]); // Empty row for spacing
      }
    }

    if (sectionsToInclude.contains(ReportSection.cqDailyBreakdown)) {
      // CQ Daily Breakdown
      if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) {
        sheet.appendRow(['CQ Daily Breakdown']);
        sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
            CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
        sheet.appendRow(['Date', 'Percentage', 'Quality Rating']);
        for (var entry in summary.cqSummary!.entries) {
          sheet.appendRow([
            DateFormat('dd-MMM-yyyy').format(entry.auditDate),
            entry.percentage.toStringAsFixed(2) + '%',
            _getQualityRating(entry.percentage),
          ]);
        }
        sheet.appendRow([]); // Empty row for spacing
      }
    }

    // Save the Excel file
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/Advisor_Desk_Report_${summary.formattedDateRange.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  String _getQualityRating(double percentage) {
    if (percentage >= 95) return 'Excellent';
    if (percentage >= 85) return 'Good';
    if (percentage >= 75) return 'Average';
    if (percentage >= 60) return 'Below Average';
    return 'Poor';
  }
}
