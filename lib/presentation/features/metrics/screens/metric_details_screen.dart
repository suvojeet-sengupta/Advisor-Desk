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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: _getTitle()),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    summary.formattedMonthYear.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.grey.shade600,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.calendar_month_rounded, size: 18, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
          _buildDetailsContent(context),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
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
          Icons.av_timer_rounded,
        );
      case MetricType.avgCalls:
        return _buildCalculationDetails(
          context,
          'Average Calls',
          summary.averageDailyCalls.toStringAsFixed(2),
          _getAverageCallsCalculation(),
          Icons.query_stats_rounded,
        );
    }
  }

  Widget _buildTotalCallsDetails(BuildContext context) {
    final theme = Theme.of(context);
    if (summary.entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomCard(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                   Icon(Icons.call_end_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
                   const SizedBox(height: 16),
                   const Text(
                     'No call entries found for this month.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'TOTAL CALLS',
                                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                summary.totalCalls.toString(),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: theme.dividerColor.withOpacity(0.05)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              context,
                              'Billable',
                              summary.billableCalls.toString(),
                              theme.colorScheme.tertiary,
                              Icons.verified_rounded,
                            ),
                          ),
                          Container(height: 40, width: 1, color: theme.dividerColor.withOpacity(0.05)),
                          Expanded(
                            child: _buildMiniStat(
                              context,
                              'Non-Billable',
                              summary.totalNonBillableCalls.toString(),
                              theme.colorScheme.error,
                              Icons.cancel_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'DAILY BREAKDOWN',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
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
                return _buildDailyEntryCard(
                  context,
                  entry,
                  '${entry.callCount}',
                  'Calls',
                  theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    if (summary.entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomCard(
             padding: const EdgeInsets.all(40),
             child: Center(
               child: Column(
                 children: [
                   Icon(Icons.timer_off_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
                   const SizedBox(height: 16),
                   const Text('No login entries found.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL LOGIN HOURS',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${summary.totalLoginHours.toStringAsFixed(2)}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      Text(
                        'HOURS : MINUTES : SECONDS',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.withOpacity(0.6), fontSize: 9),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(summary.totalLoginHours),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                 Text(
                  'DAILY BREAKDOWN',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
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
                return _buildDailyEntryCard(
                  context,
                  entry,
                  '${entry.totalLoginTimeInHours.toStringAsFixed(2)}',
                  'Hrs',
                  theme.colorScheme.tertiary,
                  subtitle: entry.formattedLoginTime,
                );
              },
              childCount: summary.entries.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDailyEntryCard(BuildContext context, DailyEntry entry, String value, String unit, Color color, {String? subtitle}) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(entry.date),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  DateFormat('EEE').format(entry.date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(entry.date),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  )
                else
                   Text(
                    DateFormat('EEEE').format(entry.date),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: theme.textTheme.labelSmall?.copyWith(color: color.withOpacity(0.6), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationDetails(
      BuildContext context, String title, String value, String calculation, IconData icon) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: theme.colorScheme.primary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'CALCULATION LOGIC',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                    ),
                    child: Text(
                      calculation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontFamily: 'Monospace',
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
