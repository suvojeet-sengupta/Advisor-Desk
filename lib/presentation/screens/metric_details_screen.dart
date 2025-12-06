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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: _getTitle()),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Text(
                summary.formattedMonthYear.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildDetailsContent(context),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                   Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   const Text(
                     'No call entries found for this month.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey),
                   ),
                ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        context,
                        'Total Calls',
                        summary.totalCalls.toString(),
                        Theme.of(context).colorScheme.primary,
                        Icons.call_rounded,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        context,
                        'Billable Calls',
                        summary.billableCalls.toString(),
                        Theme.of(context).colorScheme.tertiary,
                        Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        context,
                        'Non-Billable Calls',
                        summary.totalNonBillableCalls.toString(),
                        Theme.of(context).colorScheme.error,
                        Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'DAILY BREAKDOWN',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = summary.entries[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          DateFormat('dd').format(entry.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                               DateFormat('EEEE').format(entry.date),
                               style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                             Text(
                               DateFormat('MMM yyyy').format(entry.date),
                               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        ),
                        child: Text(
                          '${entry.callCount}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const CustomCard(
             padding: EdgeInsets.all(32),
             child: Center(
               child: Text('No login entries found for this month.', style: TextStyle(color: Colors.grey)),
             ),
          ),
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: _buildSummaryRow(
                    context,
                    'Total Login Hours',
                    '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
                    Theme.of(context).colorScheme.tertiary,
                    Icons.timer_rounded,
                    subtitle: '(${_formatDuration(summary.totalLoginHours)})',
                  ),
                ),
                const SizedBox(height: 24),
                 Text(
                  'DAILY BREAKDOWN',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = summary.entries[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                     children: [
                       Container(
                        padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          DateFormat('dd').format(entry.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                               DateFormat('EEEE').format(entry.date),
                               style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                             Text(
                               DateFormat('MMM yyyy').format(entry.date),
                               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
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
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                     ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(
                context,
                title,
                value,
                Theme.of(context).colorScheme.primary,
                Icons.analytics_rounded,
              ),
              const SizedBox(height: 24),
              Text(
                'CALCULATION LOGIC',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: Text(
                  calculation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, fontFamily: 'Monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color valueColor, IconData icon, {String? subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
             color: valueColor.withOpacity(0.1),
             shape: BoxShape.circle,
          ),
          child: Icon(icon, color: valueColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
               if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
               ]
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  String _getAverageLoginHoursCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average login hours.';
    }
    return 'Total Login Hours: ${summary.totalLoginHours.toStringAsFixed(2)} Hrs\n'
           'Total Login Days: ${summary.loginDays} days\n'
           'Equation:\n${summary.totalLoginHours.toStringAsFixed(2)} / ${summary.loginDays} = ${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs';
  }

  String _getAverageCallsCalculation() {
    if (summary.entries.isEmpty) {
      return 'No entries to calculate average calls.';
    }
    return 'Total Calls: ${summary.totalCalls} Calls\n'
           'Total Login Days: ${summary.loginDays} days\n'
           'Equation:\n${summary.totalCalls} / ${summary.loginDays} = ${summary.averageDailyCalls.toStringAsFixed(2)} Calls';
  }
}
