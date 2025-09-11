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
        return 'Login Hours Details';
      case MetricType.avgLoginHours:
        return 'Average Login Hours Details';
      case MetricType.avgCalls:
        return 'Average Calls Details';
    }
  }

  String _formatDuration(double totalHours) {
    final int hours = totalHours.truncate();
    final int minutes = ((totalHours - hours) * 60).truncate();
    final int seconds = ((((totalHours - hours) * 60) - minutes) * 60).truncate();
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                summary.formattedMonthYear,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          _buildDetailsContent(context),
        ],
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    switch (metricType) {
      case MetricType.totalCalls:
        return _buildTotalCallsDetails(context);
      case MetricType.totalLoginHours:
        return _buildTotalLoginHoursDetails(context);
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
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const CustomCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No daily entries found for this month.'),
              ),
            ),
          ),
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
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
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
              childCount: summary.entries.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLoginHoursDetails(BuildContext context) {
    if (summary.entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const CustomCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No daily entries found for this month.'),
              ),
            ),
          ),
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  child: _buildSummaryRow(
                    context,
                    'Total Login Hours',
                    '${summary.totalLoginHours.toStringAsFixed(2)} Hrs (${_formatDuration(summary.totalLoginHours)})',
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Daily Login Entries',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = summary.entries[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                      child: Text(
                        DateFormat('dd').format(entry.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    title: Text('Date: ${DateFormat('MMM dd, yyyy').format(entry.date)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.totalLoginTimeInHours.toStringAsFixed(2)} Hrs',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                        Text(
                          entry.formattedLoginTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: summary.entries.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationDetails(
      BuildContext context, String title, String value, String calculation) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: CustomCard(
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
        ),
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
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getAverageLoginHoursCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average login hours.';
    }
    return 'Total Login Hours: ${summary.totalLoginHours.toStringAsFixed(2)} Hrs\nTotal Login Days: ${summary.loginDays} days\nAverage Login Hours: ${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs\n\nEquation:\n${summary.totalLoginHours.toStringAsFixed(2)} Hrs / ${summary.loginDays} days = ${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs';
  }

  String _getAverageCallsCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average calls.';
    }
    return 'Total Calls: ${summary.totalCalls} Calls\nTotal Login Days: ${summary.loginDays} days\nAverage Calls: ${summary.averageDailyCalls.toStringAsFixed(2)} Calls\n\nEquation:\n${summary.totalCalls} Calls / ${summary.loginDays} days = ${summary.averageDailyCalls.toStringAsFixed(2)} Calls';
  }
}
