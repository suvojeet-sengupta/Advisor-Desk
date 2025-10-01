import 'dart:io';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/report_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/generate_excel_report_usecase.dart';
import 'package:advisor_desk/domain/usecases/generate_pdf_report_usecase.dart';
import 'package:open_file/open_file.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_bloc.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_event.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_state.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/utils/rate_app_helper.dart';

class AllReportsScreen extends StatelessWidget {
  final Profile profile;
  const AllReportsScreen({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllReportsBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(LoadAllMonthlySummaries()),
      child: AllReportsView(profile: profile),
    );
  }
}

class AllReportsView extends StatelessWidget {
  final Profile profile;
  const AllReportsView({Key? key, required this.profile}) : super(key: key);

  Future<void> _generateAndSharePdf(BuildContext context, ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Generating PDF Report...")));

    try {
      final generatePdf = GeneratePdfReportUseCase(context.read<PerformanceRepository>());
      final pdfBytes = await generatePdf.execute(summary, sectionsToInclude, profile);

      final tempDir = await getTemporaryDirectory();
      final fileName = "Advisor_Desk_Report_${summary.formattedDateRange.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf";
      final file = await File('${tempDir.path}/$fileName').writeAsBytes(pdfBytes);

      final xFile = XFile(file.path, mimeType: "application/pdf");
      await Share.shareXFiles([xFile], subject: "Advisor Desk Report - ${summary.formattedDateRange}");
      InAppReviewHelper.incrementActionCountAndRequestReview();

    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Error creating PDF report: $e")));
    }
  }

  Future<void> _generateAndShareExcel(BuildContext context, ReportSummary summary, List<ReportSection> sectionsToInclude, Profile profile) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Generating Excel Report...")));

    try {
      final generateExcel = GenerateExcelReportUseCase(context.read<PerformanceRepository>());
      final excelFile = await generateExcel.execute(summary, sectionsToInclude, profile);

      final xFile = XFile(excelFile.path, mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      await Share.shareXFiles([xFile], subject: "Advisor Desk Report - ${summary.formattedDateRange}");
      InAppReviewHelper.incrementActionCountAndRequestReview();

    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Error creating Excel report: \$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'All Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Customize Report Options',
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRouter.reportOptionsRoute);
              if (result != null && result is Map<String, dynamic>) {
                final startDate = result['startDate'] as DateTime;
                final endDate = result['endDate'] as DateTime;
                final selectedSections = result['selectedSections'] as List<ReportSection>;

                // Fetch ReportSummary for the selected date range
                final reportSummary = await context.read<PerformanceRepository>().getReportSummary(startDate, endDate);

                // Show a dialog to choose PDF or Excel
                showDialog(context: context, builder: (dialogContext) => AlertDialog(
                  title: const Text('Export Report As'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('PDF'),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _generateAndSharePdf(context, reportSummary, selectedSections, profile);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.table_chart),
                        title: const Text('Excel'),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _generateAndShareExcel(context, reportSummary, selectedSections, profile);
                        },
                      ),
                    ],
                  ),
                ));
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Left to Right Swipe (पिछली स्क्रीन पर जाने के लिए)
          if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<AllReportsBloc, AllReportsState>(
          builder: (context, state) {
            if (state.status == AllReportsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.summaries.isEmpty) {
              return EmptyStateWidget(
                message: 'No monthly reports found.',
                illustrationPath: 'assets/images/no_data.svg',
                onRetry: () => context.read<AllReportsBloc>().add(LoadAllMonthlySummaries()),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.summaries.length,
              itemBuilder: (context, index) {
                final summary = state.summaries[index];
                return _buildReportCard(context, summary, profile);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MonthlySummary summary, Profile profile) {
    final formatter = NumberFormat('#,##0.00');
    return InkWell(
      onTap: () async { // Made onTap async
        final startDate = DateTime(summary.year, summary.month, 1);
        final endDate = DateTime(summary.year, summary.month + 1, 1).subtract(const Duration(microseconds: 1)); // End of the last day

        // Fetch ReportSummary for the selected date range
        final reportSummary = await context.read<PerformanceRepository>().getReportSummary(startDate, endDate);

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Export Report As'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _generateAndSharePdf(context, reportSummary, ReportSection.values, profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Excel'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _generateAndShareExcel(context, reportSummary, ReportSection.values, profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.formattedMonthYear,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.call, 'Total Calls', '${summary.totalCalls}', Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.timer, 'Total Hours', '${formatter.format(summary.totalLoginHours)} hrs', Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.monetization_on, 'Total Salary', '₹${formatter.format(summary.totalSalary)}', Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8), // Added SizedBox for spacing
            _buildInfoRow(context, Icons.account_balance_wallet, 'Net Salary', '₹${formatter.format(summary.netSalary)}', Theme.of(context).colorScheme.primary), // Added Net Salary row
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text('$label: ', style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}