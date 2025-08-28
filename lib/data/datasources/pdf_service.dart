import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<List<int>> generateReportPdf(ReportSummary summary,
      List<ReportSection> sectionsToInclude, Profile profile) async {
    // Load fonts and SVG in the main isolate
    final regularFontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final playStoreIconSvg = await rootBundle.loadString('assets/images/google-play-store-icon.svg');

    // Use compute to run PDF generation in a separate isolate
    return compute(_generatePdfInBackground, {
      'summary': summary,
      'sectionsToInclude': sectionsToInclude,
      'profile': profile,
      'regularFontData': regularFontData,
      'boldFontData': boldFontData,
      'playStoreIconSvg': playStoreIconSvg,
    });
  }
}

// This function runs in a separate isolate
Future<List<int>> _generatePdfInBackground(Map<String, dynamic> params) async {
  final ReportSummary summary = params['summary'];
  final List<ReportSection> sectionsToInclude = params['sectionsToInclude'];
  final Profile profile = params['profile'];
  final ByteData regularFontData = params['regularFontData'];
  final ByteData boldFontData = params['boldFontData'];
  final String playStoreIconSvg = params['playStoreIconSvg'];

  final pdf = pw.Document();
  final formatter = NumberFormat('#,##0.00');

  final regularFont = pw.Font.ttf(regularFontData);
  final boldFont = pw.Font.ttf(boldFontData);

  final pw.ThemeData theme = pw.ThemeData.withFont(
    base: regularFont,
    bold: boldFont,
  );

  final PdfColor primaryColor = PdfColor.fromHex('#1A237E');
  final PdfColor secondaryColor = PdfColor.fromHex('#FFFFFF');
  final PdfColor textColor = PdfColor.fromHex('#333333');
  final PdfColor cardBgColor = PdfColor.fromHex('#F5F5F5');

  pw.Widget _buildHeader(pw.Context context, String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Advisor Desk Performance Report',
            style: pw.TextStyle(
                fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Period: ${summary.formattedDateRange}',
            style: pw.TextStyle(fontSize: 16, color: textColor),
          ),
          if (profile.name != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              'Advisor: ${profile.name!}',
              style: pw.TextStyle(fontSize: 16, color: textColor),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Text(
            title,
            style: pw.TextStyle(
                fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoCard(
      {required String title, required List<pw.Widget> children}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: cardBgColor,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: textColor)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  List<pw.Widget> content = [];

  if (sectionsToInclude.contains(ReportSection.monthlySummary)) {
    content.add(
      _buildInfoCard(
        title: 'Overall Summary',
        children: [
          _buildInfoRow('Total Login Hours',
              '${formatter.format(summary.totalLoginHours)} hrs'),
          _buildInfoRow(
              'Total Calls', summary.totalCalls.toString()),
          _buildInfoRow('Average Daily Hours',
              '${formatter.format(summary.averageDailyLoginHours)} hrs'),
          _buildInfoRow('Average Daily Calls',
              formatter.format(summary.averageDailyCalls)),
        ],
      ),
    );
  }

  if (sectionsToInclude.contains(ReportSection.csatSummary) &&
      summary.csatSummary != null &&
      summary.csatSummary!.entries.isNotEmpty) {
    content.add(
      _buildInfoCard(
        title: 'CSAT Performance',
        children: [
          _buildInfoRow('Total T2 Count',
              summary.csatSummary!.totalT2Count.toString()),
          _buildInfoRow('Total B2 Count',
              summary.csatSummary!.totalB2Count.toString()),
          _buildInfoRow('Total N Count',
              summary.csatSummary!.totalNCount.toString()),
          _buildInfoRow('Total Survey Hits',
              summary.csatSummary!.totalSurveyHits.toString()),
          _buildInfoRow('Monthly CSAT Percentage',
              '${formatter.format(summary.csatSummary!.monthlyCSATPercentage)}%'),
          _buildInfoRow('Average Daily CSAT Score',
              '${formatter.format(summary.csatSummary!.averageScore)}%'),
        ],
      ),
    );
  }

  if (sectionsToInclude.contains(ReportSection.cqSummary) &&
      summary.cqSummary != null &&
      summary.cqSummary!.entries.isNotEmpty) {
    content.add(
      _buildInfoCard(
        title: 'CQ Performance',
        children: [
          _buildInfoRow('Total CQ Entries',
              summary.cqSummary!.entries.length.toString()),
          _buildInfoRow('Average CQ Score',
              formatter.format(summary.cqSummary!.averageScore)),
        ],
      ),
    );
  }

  if (sectionsToInclude.contains(ReportSection.salaryDetails)) {
    content.add(
      _buildInfoCard(
        title: 'Salary Details',
        children: [
          _buildInfoRow(
              'Base Salary', 'Rs. ${formatter.format(summary.baseSalary)}'),
          _buildInfoRow(
              'Bonus Amount', 'Rs. ${formatter.format(summary.bonusAmount)}'),
          _buildInfoRow(
              'CSAT Bonus', 'Rs. ${formatter.format(summary.csatBonus)}'),
          _buildInfoRow('Gross Salary',
              'Rs. ${formatter.format(summary.totalSalary + summary.csatBonus)}'),
          _buildInfoRow('TDS Deduction',
              'Rs. -${formatter.format(summary.tdsDeduction)}'),
          pw.Divider(color: primaryColor.shade(0.5)),
          _buildInfoRow(
              'Net Salary', 'Rs. ${formatter.format(summary.netSalary)}'),
        ],
      ),
    );
  }

  pw.Widget _buildTable(String title, List<String> headers, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor),
          headerDecoration: pw.BoxDecoration(color: primaryColor),
          cellAlignment: pw.Alignment.center,
          cellStyle: pw.TextStyle(color: textColor),
        ),
        pw.SizedBox(height: 20),
      ]
    );
  }

  if (sectionsToInclude.contains(ReportSection.dailyEntries) && summary.entries.isNotEmpty) {
    content.add(
      _buildTable(
        'Daily Entries',
        ['Date', 'Login Time', 'Call Count'],
        summary.entries
            .map((entry) => [
                  DateFormat('dd-MMM-yyyy').format(entry.date),
                  entry.formattedLoginTime,
                  entry.callCount.toString(),
                ])
            .toList(),
      ),
    );
  }

  if (sectionsToInclude.contains(ReportSection.csatDailyBreakdown) &&
      summary.csatSummary != null &&
      summary.csatSummary!.entries.isNotEmpty) {
    content.add(
      _buildTable(
        'CSAT Daily Breakdown',
        ['Date', 'T2', 'B2', 'N', 'CSAT %'],
        summary.csatSummary!.entries.map((entry) {
          final total = entry.t2Count + entry.b2Count + entry.nCount;
          final csatPercentage =
              total == 0 ? 0.0 : ((entry.t2Count - entry.b2Count) / total) * 100;
          return [
            DateFormat('dd-MMM-yyyy').format(entry.date),
            entry.t2Count.toString(),
            entry.b2Count.toString(),
            entry.nCount.toString(),
            '${csatPercentage.toStringAsFixed(2)}%',
          ];
        }).toList(),
      ),
    );
  }

  if (sectionsToInclude.contains(ReportSection.cqDailyBreakdown) &&
      summary.cqSummary != null &&
      summary.cqSummary!.entries.isNotEmpty) {
    content.add(
      _buildTable(
        'CQ Daily Breakdown',
        ['Date', 'Percentage', 'Quality Rating'],
        summary.cqSummary!.entries
            .map((entry) => [
                  DateFormat('dd-MMM-yyyy').format(entry.auditDate),
                  '${entry.percentage.toStringAsFixed(2)}%',
                  _getQualityRating(entry.percentage),
                ])
            .toList(),
      ),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => [
        _buildHeader(context, 'Performance Report'),
        ...content,
      ],
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20, left: 20, right: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Generated by Advisor Desk',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                  pw.SizedBox(height: 5),
                  pw.UrlLink(
                    destination: 'https://play.google.com/store/apps/details?id=com.suvojeet.advisordesk',
                    child: pw.Row(
                      children: [
                        pw.SvgImage(svg: playStoreIconSvg, width: 20, height: 20),
                        pw.SizedBox(width: 5),
                        pw.Text(
                          'Download on Playstore',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: 'https://play.google.com/store/apps/details?id=com.suvojeet.advisordesk',
                width: 60,
                height: 60,
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

String _getQualityRating(double percentage) {
  if (percentage >= 95) return 'Excellent';
  if (percentage >= 85) return 'Good';
  if (percentage >= 75) return 'Average';
  if (percentage >= 60) return 'Below Average';
  return 'Poor';
}