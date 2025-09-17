import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

/// A widget that displays a summary of the user's monthly performance.
///
/// This widget is used on the dashboard to show key metrics for the selected month.
class SummarySection extends StatelessWidget {
  /// The monthly summary data.
  final MonthlySummary summary;

  /// Creates a summary section.
  const SummarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Total Calls',
              summary.totalCalls.toString(),
              Icons.call,
              Theme.of(context).colorScheme.primary,
            ),
            _buildSummaryRow(
              context,
              'Non-billable Calls',
              summary.totalNonBillableCalls.toString(),
              Icons.phone_disabled,
              Theme.of(context).colorScheme.error,
            ),
            _buildSummaryRow(
              context,
              'Billable Calls',
              summary.billableCalls.toString(),
              Icons.phone_in_talk,
              Colors.green,
            ),
            _buildSummaryRow(
              context,
              'Total Login Hours',
              '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
              Icons.timer,
              Theme.of(context).colorScheme.secondary,
            ),
            _buildSummaryRow(
              context,
              'Average Daily Login Hours',
              '${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs',
              Icons.access_time,
              Theme.of(context).colorScheme.tertiary,
            ),
            _buildSummaryRow(
              context,
              'Average Daily Calls',
              summary.averageDailyCalls.toStringAsFixed(0),
              Icons.phone,
              Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row for displaying a summary detail.
  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
