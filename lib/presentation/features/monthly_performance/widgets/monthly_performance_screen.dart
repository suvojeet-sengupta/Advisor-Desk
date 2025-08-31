import 'package:advisor_desk/presentation/common/widgets/custom_divider.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_card.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/daily_entries_section.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class MonthlyPerformanceScreen extends StatelessWidget {
  final MonthlySummary summary;

  const MonthlyPerformanceScreen({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: summary.formattedMonthYear),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Right to Left Swipe (अगली स्क्रीन पर जाने के लिए)
          if ((details.primaryVelocity ?? 0) < -200) {
            Navigator.pushReplacementNamed(context, AppRouter.allReportsRoute);
          }
          // Left to Right Swipe (पिछली स्क्रीन पर जाने के लिए)
          else if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardCard(
                      title: 'Total Calls',
                      value: summary.totalCalls.toString(),
                      icon: Icons.call,
                      iconColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.metricDetailsRoute,
                          arguments: {
                            'metricType': MetricType.totalCalls,
                            'summary': summary,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Non-billable Calls',
                      value: summary.totalNonBillableCalls.toString(),
                      icon: Icons.phone_disabled,
                      iconColor: Theme.of(context).colorScheme.error,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.monthlyDataRoute,
                          arguments: {
                            'month': summary.month,
                            'year': summary.year,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Billable Calls',
                      value: summary.billableCalls.toString(),
                      icon: Icons.phone_in_talk,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.metricDetailsRoute,
                          arguments: {
                            'metricType': MetricType.totalCalls, // Billable calls are part of total calls details
                            'summary': summary,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Total Login Hours',
                      value: '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
                      icon: Icons.timer,
                      iconColor: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.metricDetailsRoute,
                          arguments: {
                            'metricType': MetricType.totalLoginHours,
                            'summary': summary,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Avg. Login Hours',
                      value: summary.averageDailyLoginHours.toStringAsFixed(2),
                      icon: Icons.timer,
                      iconColor: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.metricDetailsRoute,
                          arguments: {
                            'metricType': MetricType.avgLoginHours,
                            'summary': summary,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Avg. Calls',
                      value: summary.averageDailyCalls.toStringAsFixed(2),
                      icon: Icons.call,
                      iconColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.metricDetailsRoute,
                          arguments: {
                            'metricType': MetricType.avgCalls,
                            'summary': summary,
                          },
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'CSAT Score',
                      value: '${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%',
                      icon: Icons.sentiment_satisfied_alt,
                      iconColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        if (summary.csatSummary != null) {
                          Navigator.pushNamed(context, AppRouter.csatDetailsRoute, arguments: summary.csatSummary);
                        }
                      },
                    ),
                    DashboardCard(
                      title: 'CQ Score',
                      value: '${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%',
                      icon: Icons.assessment,
                      iconColor: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        if (summary.cqSummary != null) {
                          Navigator.pushNamed(context, AppRouter.cqDetailsRoute, arguments: summary.cqSummary);
                        }
                      },
                    ),
                    DashboardCard(
                      title: 'Net Salary',
                      value: '₹${summary.netSalary.toStringAsFixed(2)}',
                      icon: Icons.currency_rupee,
                      iconColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.salaryDetailsRoute,
                          arguments: summary,
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Login Days',
                      value: summary.loginDays.toString(),
                      icon: Icons.calendar_today,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    
                    DashboardCard(
                      title: 'Bonus Achieved',
                      value: summary.isBonusAchieved ? 'Yes' : 'No',
                      icon: summary.isBonusAchieved ? Icons.check_circle : Icons.cancel,
                      iconColor: summary.isBonusAchieved ? Colors.green : Colors.red,
                    ),
                    DashboardCard(
                      title: 'CSAT Bonus Achieved',
                      value: summary.isCSATBonusAchieved ? 'Yes' : 'No',
                      icon: summary.isCSATBonusAchieved ? Icons.check_circle : Icons.cancel,
                      iconColor: summary.isCSATBonusAchieved ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
              const CustomDivider(),
              _buildSectionTitle(context, 'Salary Breakdown'),
              const SizedBox(height: 8),
              _buildSalaryBreakdown(context, summary.salaryBreakdown),
              const CustomDivider(),
              DailyEntriesSection(entries: summary.entries),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSalaryBreakdown(BuildContext context, Map<String, double> breakdown) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: breakdown.entries.map((entry) {
          final isCallEntry = entry.key.toLowerCase().contains('calls');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  isCallEntry
                      ? entry.value.toInt().toString()
                      : '₹${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

