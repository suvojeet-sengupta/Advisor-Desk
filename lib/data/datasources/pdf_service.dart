import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<List<int>> generateReportPdf(ReportSummary summary, List<ReportSection> sectionsToInclude) async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,##0.00');

    // Helper function to build the common header for each page
    pw.Widget _buildHeader(pw.Context context, String title) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Advisor Desk Performance Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Period: ${summary.formattedDateRange}', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
        ],
      );
    }

    // Add content based on selected sections
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          if (sectionsToInclude.contains(ReportSection.monthlySummary)) ...[
            _buildHeader(context, 'Summary'),
            pw.Table.fromTextArray(
              headers: ['Description', 'Value'],
              data: [
                ['Total Login Hours', '${formatter.format(summary.totalLoginHours)} hrs'],
                ['Total Calls', summary.totalCalls.toString()],
                ['Average Daily Hours', '${formatter.format(summary.averageDailyLoginHours)} hrs'],
                ['Average Daily Calls', formatter.format(summary.averageDailyCalls)],
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          if (sectionsToInclude.contains(ReportSection.csatSummary)) ...[
            if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) ...[
              _buildHeader(context, 'Overall CSAT Performance'),
              pw.Table.fromTextArray(
                headers: ['Description', 'Value'],
                data: [
                  ['Total T2 Count', summary.csatSummary!.totalT2Count.toString()],
                  ['Total B2 Count', summary.csatSummary!.totalB2Count.toString()],
                  ['Total N Count', summary.csatSummary!.totalNCount.toString()],
                  ['Total Survey Hits', summary.csatSummary!.totalSurveyHits.toString()],
                  ['Monthly CSAT Percentage', '${formatter.format(summary.csatSummary!.monthlyCSATPercentage)}%'],
                  ['Average Daily CSAT Score', '${formatter.format(summary.csatSummary!.averageScore)}%'],
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          ],

          if (sectionsToInclude.contains(ReportSection.cqSummary)) ...[
            if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) ...[
              _buildHeader(context, 'Overall CQ Performance'),
              pw.Table.fromTextArray(
                headers: ['Description', 'Value'],
                data: [
                  ['Total CQ Entries', summary.cqSummary!.entries.length.toString()],
                  ['Average CQ Score', formatter.format(summary.cqSummary!.averageScore)],
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          ],

          if (sectionsToInclude.contains(ReportSection.salaryDetails)) ...[
            _buildHeader(context, 'Salary Details'),
            pw.Table.fromTextArray(
              headers: ['Description', 'Amount', 'Status'],
              data: [
                ['Base Salary', 'Rs. ${formatter.format(summary.baseSalary)}', ''],
                ['Bonus Amount', 'Rs. ${formatter.format(summary.bonusAmount)}', summary.isBonusAchieved ? 'Achieved' : 'Not Achieved'],
                ['CSAT Bonus', 'Rs. ${formatter.format(summary.csatBonus)}', summary.isCSATBonusAchieved ? 'Achieved' : 'Not Achieved'],
                ['Gross Salary', 'Rs. ${formatter.format(summary.totalSalary + summary.csatBonus)}', ''],
                ['TDS Deduction', 'Rs. -${formatter.format(summary.tdsDeduction)}', ''],
                ['Net Salary', 'Rs. ${formatter.format(summary.netSalary)}', ''],
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          if (sectionsToInclude.contains(ReportSection.dailyEntries)) ...[
            if (summary.entries.isNotEmpty) ...[
              _buildHeader(context, 'Daily Entries'),
              pw.Table.fromTextArray(
                headers: ['Date', 'Login Time', 'Call Count'],
                data: summary.entries.map((entry) => [
                  DateFormat('dd-MMM-yyyy').format(entry.date),
                  entry.formattedLoginTime,
                  entry.callCount.toString(),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
            ],
          ],

          if (sectionsToInclude.contains(ReportSection.csatDailyBreakdown)) ...[
            if (summary.csatSummary != null && summary.csatSummary!.entries.isNotEmpty) ...[
              _buildHeader(context, 'CSAT Daily Breakdown'),
              pw.Table.fromTextArray(
                headers: ['Date', 'T2', 'B2', 'N', 'CSAT %'],
                data: summary.csatSummary!.entries.map((entry) {
                  final total = entry.t2Count + entry.b2Count + entry.nCount;
                  final csatPercentage = total == 0 ? 0.0 : ((entry.t2Count - entry.b2Count) / total) * 100;
                  return [
                    DateFormat('dd-MMM-yyyy').format(entry.date),
                    entry.t2Count.toString(),
                    entry.b2Count.toString(),
                    entry.nCount.toString(),
                    '${csatPercentage.toStringAsFixed(2)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
            ],
          ],

          if (sectionsToInclude.contains(ReportSection.cqDailyBreakdown)) ...[
            if (summary.cqSummary != null && summary.cqSummary!.entries.isNotEmpty) ...[
              _buildHeader(context, 'CQ Daily Breakdown'),
              pw.Table.fromTextArray(
                headers: ['Date', 'Percentage', 'Quality Rating'],
                data: summary.cqSummary!.entries.map((entry) => [
                  DateFormat('dd-MMM-yyyy').format(entry.auditDate),
                  entry.percentage.toStringAsFixed(2) + '%',
                  _getQualityRating(entry.percentage),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
            ],
          ],
        ],
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
}