import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';
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

  pw.Widget _buildHeader(pw.Context context, String title, String dateRange, String? advisorName) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Advisor Desk',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
              pw.Text(
                'Performance Report',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Divider(thickness: 0.5, color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          if (context.pageNumber == 1) ...[
             pw.Text(
              'Performance Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Period: $dateRange',
              style: pw.TextStyle(fontSize: 14, color: textColor),
            ),
            if (advisorName != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                'Advisor: $advisorName',
                style: pw.TextStyle(fontSize: 14, color: textColor),
              ),
            ],
            pw.SizedBox(height: 20),
          ]
        ],
      ),
    );
  }

  pw.Widget _buildInfoCard(
      {required String title, required List<pw.Widget> children}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: cardBgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: textColor, fontSize: 10)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal, 
                  color: textColor,
                  fontSize: 10,
              )),
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
              '${formatter.format(summary.csatSummary!.monthlyCSATPercentage)}%', isTotal: true),
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
              formatter.format(summary.cqSummary!.averageScore), isTotal: true),
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
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          _buildInfoRow(
              'Net Salary', 'Rs. ${formatter.format(summary.netSalary)}', isTotal: true),
        ],
      ),
    );
  }

  if (summary.customRateEntries.isNotEmpty) {
    content.add(
      _buildInfoCard(
        title: 'Custom Rate Details',
        children: [
          _buildInfoRow('Total Calls with Custom Rate',
              summary.totalCustomRateCalls.toString()),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          ...summary.customRateEntries.map((entry) {
            return _buildInfoRow(
              '${DateFormat('dd MMM yyyy').format(entry.date)}',
              'Rs. ${formatter.format(entry.customCallRate)}',
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildTable(String title, List<String> headers, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor, fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: primaryColor),
          cellAlignment: pw.Alignment.center,
          cellStyle: pw.TextStyle(color: textColor, fontSize: 8),
          headerHeight: 25,
          cellHeight: 20,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        ),
        pw.SizedBox(height: 15),
      ]
    );
  }

  if (sectionsToInclude.contains(ReportSection.dailyEntries) && summary.entries.isNotEmpty) {
    const chunkSize = 25;
    for (int i = 0; i < summary.entries.length; i += chunkSize) {
      final end = (i + chunkSize < summary.entries.length) ? i + chunkSize : summary.entries.length;
      final chunk = summary.entries.sublist(i, end);
      content.add(
        _buildTable(
          i == 0 ? 'Daily Entries' : 'Daily Entries (cont.)',
          ['Date', 'Login Hours', 'Call Count'],
          chunk
              .map((entry) => [
                    DateFormat('dd-MMM-yyyy').format(entry.date),
                    entry.formattedLoginTime,
                    entry.callCount.toString(),
                  ])
              .toList(),
        ),
      );
    }
  }

  if (sectionsToInclude.contains(ReportSection.csatDailyBreakdown) &&
      summary.csatSummary != null &&
      summary.csatSummary!.entries.isNotEmpty) {
    const chunkSize = 25;
    final entries = summary.csatSummary!.entries;
    for (int i = 0; i < entries.length; i += chunkSize) {
      final end = (i + chunkSize < entries.length) ? i + chunkSize : entries.length;
      final chunk = entries.sublist(i, end);
      content.add(
        _buildTable(
          i == 0 ? 'CSAT Daily Breakdown' : 'CSAT Daily Breakdown (cont.)',
          ['Date', 'T2', 'B2', 'N', 'CSAT %'],
          chunk.map((entry) {
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
  }

  if (sectionsToInclude.contains(ReportSection.cqDailyBreakdown) &&
      summary.cqSummary != null &&
      summary.cqSummary!.entries.isNotEmpty) {
    const chunkSize = 25;
    final entries = summary.cqSummary!.entries;
    for (int i = 0; i < entries.length; i += chunkSize) {
      final end = (i + chunkSize < entries.length) ? i + chunkSize : entries.length;
      final chunk = entries.sublist(i, end);
      content.add(
        _buildTable(
          i == 0 ? 'CQ Daily Breakdown' : 'CQ Daily Breakdown (cont.)',
          ['Date', 'Percentage', 'Quality Rating'],
          chunk
              .map((entry) => [
                    DateFormat('dd-MMM-yyyy').format(entry.auditDate),
                    '${entry.percentage.toStringAsFixed(2)}%',
                    QualityRatingHelper.getQualityRating(entry.percentage),
                  ])
              .toList(),
        ),
      );
    }
  }

  pdf.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      header: (pw.Context context) => _buildHeader(context, 'Performance Report', summary.formattedDateRange, profile.name),
      build: (pw.Context context) => content,
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Column(
            children: [
               pw.Divider(thickness: 0.5, color: PdfColors.grey300),
               pw.SizedBox(height: 5),
               pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Generated by Advisor Desk',
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.UrlLink(
                        destination: 'https://play.google.com/store/apps/details?id=com.suvojeet.advisordesk',
                        child: pw.Row(
                          children: [
                            pw.SvgImage(svg: playStoreIconSvg, width: 12, height: 12),
                            pw.SizedBox(width: 4),
                            pw.Text(
                              'Download on Playstore',
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.blue700,
                                decoration: pw.TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://play.google.com/store/apps/details?id=com.suvojeet.advisordesk',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
            ],
          )
        );
      },
    ),
  );

  return pdf.save();
}