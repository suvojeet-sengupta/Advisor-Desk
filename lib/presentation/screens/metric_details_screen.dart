import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class MetricDetailsScreen extends StatelessWidget {
  final MetricType metricType;
  final MonthlySummary summary;

  const MetricDetailsScreen({
    Key? key,
    required this.metricType,
    required this.summary,
  }) : super(key: key);

  String _getTitle() {
    switch (metricType) {
      case MetricType.totalCalls:
        return 'Total Calls Details';
      case MetricType.totalLoginHours:
        return 'Total Login Hours Details';
      case MetricType.avgLoginHours:
        return 'Average Login Hours Details';
      case MetricType.avgCalls:
        return 'Average Calls Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.formattedMonthYear,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailsContent(context),
          ],
        ),
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    final theme = Theme.of(context);
    switch (metricType) {
      case MetricType.totalCalls:
        return _buildTotalCallsDetails(context);
      case MetricType.totalLoginHours:
        return _buildCalculationDetails(
          context,
          'Total Login Hours',
          '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
          _getTotalLoginHoursCalculation(),
        );
      case MetricType.avgLoginHours:
        return _buildCalculationDetails(
          context,
          'Average Login Hours',
          '${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs',
          _getAverageLoginHoursCalculation(),
        );
      case MetricType.avgCalls:
        return _buildCalculationDetails(
          context,
          'Average Calls',
          summary.averageDailyCalls.toStringAsFixed(2),
          _getAverageCallsCalculation(),
        );
    }
  }

  Widget _buildTotalCallsDetails(BuildContext context) {
    if (summary.entries.isEmpty) {
      return const CustomCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No daily entries found for this month.'),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Column(
            children: [
              _buildSummaryRow(
                context,
                'Total Calls',
                summary.totalCalls.toString(),
                Theme.of(context).colorScheme.primary,
              ),
              _buildSummaryRow(
                context,
                'Total Billable Calls',
                summary.billableCalls.toString(),
                Theme.of(context).colorScheme.tertiary,
              ),
              _buildSummaryRow(
                context,
                'Total Non-Billable Calls',
                summary.totalNonBillableCalls.toString(),
                Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Daily Call Entries',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summary.entries.length,
          itemBuilder: (context, index) {
            final entry = summary.entries[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    DateFormat('dd').format(entry.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                title: Text('Date: ${DateFormat('MMM dd, yyyy').format(entry.date)}'),
                trailing: Text(
                  '${entry.callCount} Calls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalculationDetails(
      BuildContext context, String title, String value, String calculation) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            context,
            title,
            value,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Calculation:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            calculation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  String _getTotalLoginHoursCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate total login hours.';
    }
    String calculation = '''Sum of login hours for all daily entries:
''';
    for (var entry in summary.entries) {
      calculation +=
          '''  ${DateFormat('MMM dd').format(entry.date)}: ${entry.formattedLoginTime} (${entry.totalLoginTimeInHours.toStringAsFixed(2)} Hrs)
''';
    }
    calculation += '''
Total: ${summary.totalLoginHours.toStringAsFixed(2)} Hrs''';
    return calculation;
  }

  String _getAverageLoginHoursCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average login hours.';
    }
    return '${summary.totalLoginHours.toStringAsFixed(2)} Hrs / ${summary.loginDays} days = ${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs';
  }

  String _getAverageCallsCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average calls.';
    }
    return '${summary.totalCalls} Calls / ${summary.loginDays} days = ${summary.averageDailyCalls.toStringAsFixed(2)} Calls';
  }
}
