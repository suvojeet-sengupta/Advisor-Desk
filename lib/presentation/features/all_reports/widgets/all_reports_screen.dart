import 'dart:io';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/generate_excel_report_usecase.dart';
import 'package:open_file/open_file.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_bloc.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_event.dart';
import 'package:advisor_desk/presentation/features/all_reports/bloc/all_reports_state.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class AllReportsScreen extends StatelessWidget {
  const AllReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllReportsBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(LoadAllMonthlySummaries()),
      child: const AllReportsView(),
    );
  }
}

class AllReportsView extends StatelessWidget {
  const AllReportsView({Key? key}) : super(key: key);

  static const platform = MethodChannel('com.dishtv.agenttracker/pdf');

  Future<void> _generateAndSharePdf(BuildContext context, MonthlySummary summary) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Generating PDF Report...")));

    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final repo = context.read<PerformanceRepository>();
      final pdfBytes = await repo.generateMonthlyReportPdf(summary);
      
      final result = await platform.invokeMethod('savePdf', {
        'pdfBytes': pdfBytes,
        'fileName': "DishTV_Report_${summary.monthName}_${summary.year}.pdf"
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result ?? "PDF Saved")));

    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Failed to save PDF: '${e.message}'.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Error creating PDF report: $e")));
    }
  }

  Future<void> _generateAndShareExcel(BuildContext context, MonthlySummary summary) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Generating Excel Report...")));

    try {
      final generateExcel = GenerateExcelReportUseCase(context.read<PerformanceRepository>());
      final excelFile = await generateExcel.execute(summary);

      final xFile = XFile(excelFile.path, mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      await Share.shareXFiles([xFile], subject: "Monthly Report - ${summary.formattedMonthYear}");

    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Error creating Excel report: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Reports'),
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
              return const Center(child: Text('No monthly reports found.'));
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.summaries.length,
              itemBuilder: (context, index) {
                final summary = state.summaries[index];
                return _buildReportCard(context, summary);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MonthlySummary summary) {
    final formatter = NumberFormat('#,##0.00');
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.formattedMonthYear,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.dishTvOrange),
          ),
          const Divider(height: 24),
          _buildInfoRow(context, Icons.call, 'Total Calls', '${summary.totalCalls}', AppColors.dishTvOrangeLight),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.timer, 'Total Hours', '${formatter.format(summary.totalLoginHours)} hrs', AppColors.dishTvOrangeLight),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.monetization_on, 'Total Salary', '₹${formatter.format(summary.totalSalary)}', AppColors.dishTvOrange),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                  onPressed: () => _generateAndSharePdf(context, summary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dishTvOrange,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.table_chart),
                  label: const Text("Export Excel"),
                  onPressed: () => _generateAndShareExcel(context, summary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dishTvOrangeLight,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          )
        ],
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
