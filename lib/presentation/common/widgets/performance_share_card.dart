import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:intl/intl.dart';

class PerformanceShareCard extends StatelessWidget {
  final MonthlySummary summary;
  final Profile profile;

  const PerformanceShareCard({Key? key, required this.summary, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon/app_icon.png', width: 40, height: 40),
                const SizedBox(width: 10),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Monthly Performance Summary',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            Text(
              summary.formattedMonthYear,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            if (profile.name.isNotEmpty)
              Text(
                profile.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context,
              Icons.timer,
              'Total Login Hours',
              '${formatter.format(summary.totalLoginHours)} hrs',
              theme.colorScheme.secondary,
            ),
            _buildInfoRow(
              context,
              Icons.call,
              'Total Calls',
              summary.totalCalls.toString(),
              theme.colorScheme.secondary,
            ),
            _buildInfoRow(
              context,
              Icons.sentiment_satisfied_alt,
              'CSAT Score',
              '${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%',
              theme.colorScheme.primary,
            ),
            _buildInfoRow(
              context,
              Icons.assessment,
              'CQ Score',
              '${summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%',
              theme.colorScheme.primary,
            ),
            _buildInfoRow(
              context,
              Icons.currency_rupee,
              'Total Salary',
              'Rs. ${formatter.format(summary.totalSalary)}',
              theme.colorScheme.primary,
            ),
            _buildInfoRow(
              context,
              Icons.payments,
              'Net Salary',
              'Rs. ${formatter.format(summary.netSalary)}',
              theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Keep up the great work!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color iconColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}