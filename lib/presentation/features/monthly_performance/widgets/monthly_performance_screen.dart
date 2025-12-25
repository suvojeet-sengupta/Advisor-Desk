import 'package:advisor_desk/presentation/common/widgets/custom_divider.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/daily_entries_section.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/data/datasources/user_data_source.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyPerformanceScreen extends StatelessWidget {
  final MonthlySummary summary;

  const MonthlyPerformanceScreen({
    Key? key,
    required this.summary,
  }) : super(key: key);

  Future<void> _onSharePressed(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userId = await context.read<UserDataSource>().getCurrentUserId();
      final profile = await context.read<ProfileRepository>().getProfile(userId: userId);
      
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        Navigator.pushNamed(
          context,
          AppRouter.shareThemeSelectorRoute,
          arguments: {
            'summary': summary,
            'profile': profile,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error preparing share: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: summary.formattedMonthYear,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Stats',
            onPressed: () => _onSharePressed(context),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -200) {
            Navigator.pushReplacementNamed(context, AppRouter.allReportsRoute);
          } else if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.pop(context);
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSummary(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Performance Metrics'),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Quality Scores'),
                    const SizedBox(height: 12),
                    _buildQualityScores(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Salary Breakdown'),
                    const SizedBox(height: 12),
                    _buildSalaryBreakdown(context, summary.salaryBreakdown),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            DailyEntriesSection(entries: summary.entries),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Net Salary',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${summary.netSalary.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeroStat(context, 'Total Calls', summary.totalCalls.toString(), Icons.call),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
              _buildHeroStat(context, 'Login Hours', '${summary.totalLoginHours.toStringAsFixed(1)}h', Icons.timer),
            ],
          ),
          if (summary.totalCalls > 0) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.advisorWrappedRoute,
                    arguments: summary,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Dark background for the wrapped feel
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.amberAccent),
                label: const Text(
                  'View Your Wrapped',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          context,
          'Avg Calls',
          summary.averageDailyCalls.toStringAsFixed(1),
          Icons.analytics_outlined,
          () => _navigateToMetric(context, MetricType.avgCalls),
          Theme.of(context).colorScheme.primary,
        ),
        _buildMetricCard(
          context,
          'Avg Login',
          '${summary.averageDailyLoginHours.toStringAsFixed(1)}h',
          Icons.timelapse_rounded,
          () => _navigateToMetric(context, MetricType.avgLoginHours),
          Theme.of(context).colorScheme.secondary,
        ),
        _buildMetricCard(
          context,
          'Billable',
          summary.billableCalls.toString(),
          Icons.phone_in_talk_rounded,
          null, // Billable part of total calls
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Non-Billable',
          summary.totalNonBillableCalls.toString(),
          Icons.phone_disabled_rounded,
          () {
             Navigator.pushNamed(
                context,
                AppRouter.monthlyDataRoute,
                arguments: {'month': summary.month, 'year': summary.year},
              );
          },
          Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildQualityScores(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'CSAT Score',
            '${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(0) ?? 'N/A'}%',
            Icons.sentiment_satisfied_rounded,
            () {
              if (summary.csatSummary != null) {
                Navigator.pushNamed(context, AppRouter.csatDetailsRoute, arguments: summary.csatSummary);
              }
            },
            Colors.orange,
            isLarge: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'CQ Score',
            '${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(0) ?? 'N/A'}%',
            Icons.verified_rounded,
            () {
              if (summary.cqSummary != null) {
                 Navigator.pushNamed(context, AppRouter.cqDetailsRoute, arguments: summary.cqSummary);
              }
            },
            Colors.purple,
             isLarge: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String title, String value, IconData icon, VoidCallback? onTap, Color color, {bool isLarge = false}) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: isLarge ? 28 : 20),
              if (onTap != null) Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 24 : 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  void _navigateToMetric(BuildContext context, MetricType type) {
    Navigator.pushNamed(
      context,
      AppRouter.metricDetailsRoute,
      arguments: {
        'metricType': type,
        'summary': summary,
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSalaryBreakdown(BuildContext context, Map<String, double> breakdown) {
    return CustomCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: breakdown.entries.map((entry) {
          final isCallEntry = entry.key.toLowerCase().contains('calls');
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
            trailing: Text(
              isCallEntry
                  ? entry.value.toInt().toString()
                  : '₹${entry.value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

