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

class AllReportsView extends StatefulWidget {
  final Profile profile;
  const AllReportsView({Key? key, required this.profile}) : super(key: key);

  @override
  State<AllReportsView> createState() => _AllReportsViewState();
}

class _AllReportsViewState extends State<AllReportsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AllReportsBloc>().add(LoadMoreMonthlySummaries());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

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
        ..showSnackBar(SnackBar(content: Text("Error creating Excel report: $e")));
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
                          _generateAndSharePdf(context, reportSummary, selectedSections, widget.profile);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.table_chart),
                        title: const Text('Excel'),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _generateAndShareExcel(context, reportSummary, selectedSections, widget.profile);
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
            if (state.status == AllReportsStatus.loading && state.summaries.isEmpty) {
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
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.hasReachedMax ? state.summaries.length : state.summaries.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.summaries.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                final summary = state.summaries[index];
                return _buildReportCard(context, summary, widget.profile);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MonthlySummary summary, Profile profile) {
    final formatter = NumberFormat('#,##0.00');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 20),
      onTap: () async {
        final startDate = DateTime(summary.year, summary.month, 1);
        final endDate = DateTime(summary.year, summary.month + 1, 1).subtract(const Duration(microseconds: 1)); 

        final reportSummary = await context.read<PerformanceRepository>().getReportSummary(startDate, endDate);

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Export Report'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Export as PDF'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _generateAndSharePdf(context, reportSummary, ReportSection.values, profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: const Text('Export as Excel'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.formattedMonthYear.split(' ')[0], // Month
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                   Text(
                    summary.formattedMonthYear.split(' ')[1], // Year
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.download_rounded, color: Theme.of(context).colorScheme.primary),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactStat(context, 'Calls', '${summary.totalCalls}', Icons.call),
                _buildCompactStat(context, 'Hours', '${formatter.format(summary.totalLoginHours)}', Icons.timer),
                _buildCompactStat(context, 'Salary', '₹${formatter.format(summary.totalSalary)}', Icons.monetization_on, isHighLight: true),
              ],
            ),
          ),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Net Salary', style: Theme.of(context).textTheme.bodyMedium),
               Text(
                 '₹${formatter.format(summary.netSalary)}',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold,
                   color: Theme.of(context).colorScheme.primary,
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String label, String value, IconData icon, {bool isHighLight = false}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: isHighLight ? Theme.of(context).colorScheme.primary : Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighLight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
