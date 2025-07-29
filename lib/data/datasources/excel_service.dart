import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';

class ExcelService {
  Future<File> generateMonthlyReportExcel(MonthlySummary summary) async {
    final excel = Excel.createExcel();
    final sheet = excel['Monthly Report'];

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
      'Month: ${summary.formattedMonthYear}',
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

    // Monthly Summary
    sheet.appendRow(['Monthly Summary']);
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

    // CSAT Summary
    if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) {
      sheet.appendRow(['CSAT Summary']);
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

      sheet.appendRow(['Overall CSAT Performance']);
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
      sheet.appendRow(['Description', 'Value']);
      sheet.appendRow([
        'Total CSAT Entries',
        summary.csatSummary!.entries.length.toString()
      ]);
      sheet.appendRow([
        'Average CSAT Score',
        '${summary.csatSummary!.averageScore.toStringAsFixed(2)}%'
      ]);
      sheet.appendRow([]); // Empty row for spacing
    }

    // CQ Summary
    if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) {
      sheet.appendRow(['CQ Summary']);
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

    // Salary Details
    sheet.appendRow(['Salary Details']);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sheet.maxRows - 1));
    sheet.appendRow(['Description', 'Amount']);
    sheet.appendRow([
      'Base Salary',
      'Rs. ${summary.baseSalary.toStringAsFixed(2)}'
    ]);
    sheet.appendRow([
      'Bonus',
      'Rs. ${summary.bonusAmount.toStringAsFixed(2)}'
    ]);
    sheet.appendRow([
      'CSAT Bonus',
      'Rs. ${summary.csatBonus.toStringAsFixed(2)}'
    ]);
    sheet.appendRow([
      'Gross Salary',
      'Rs. ${(summary.totalSalary + summary.csatBonus).toStringAsFixed(2)}'
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

    // Save the Excel file
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/Advisor_Desk_Report_${summary.formattedMonthYear}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
}
