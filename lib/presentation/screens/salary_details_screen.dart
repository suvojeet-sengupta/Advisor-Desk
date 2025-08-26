import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';

class SalaryDetailsScreen extends StatelessWidget {
  final MonthlySummary monthlySummary;

  const SalaryDetailsScreen({Key? key, required this.monthlySummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final breakdown = monthlySummary.salaryBreakdown;

    return Scaffold(
      appBar: CustomAppBar(title: 'Salary Details'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Monthly Salary Breakdown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...breakdown.entries.map((entry) {
              return _buildSalaryDetailRow(
                context,
                entry.key,
                entry.value,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryDetailRow(
    BuildContext context,
    String title,
    double value,
  ) {
    final isCallEntry = title.toLowerCase().contains('calls');
    final isDeduction = title.toLowerCase().contains('deduction');
    final isNetSalary = title.toLowerCase().contains('net salary');
    final isGrossSalary = title.toLowerCase().contains('gross salary');

    IconData icon;
    Color iconColor;

    switch (title) {
      case 'Total Calls':
        icon = Icons.call;
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'Non-billable Calls':
        icon = Icons.phone_disabled;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      case 'Billable Calls':
        icon = Icons.phone_in_talk;
        iconColor = Colors.green;
        break;
      case 'Base Salary':
        icon = Icons.money;
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'Bonus Amount':
        icon = Icons.card_giftcard;
        iconColor = monthlySummary.isBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
        break;
      case 'CSAT Bonus':
        icon = Icons.star;
        iconColor = monthlySummary.isCSATBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
        break;
      case 'Gross Salary':
        icon = Icons.account_balance_wallet;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case 'TDS Deduction':
        icon = Icons.remove_circle;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      case 'Net Salary':
        icon = Icons.payments;
        iconColor = Theme.of(context).colorScheme.tertiary;
        break;
      default:
        icon = Icons.monetization_on;
        iconColor = Theme.of(context).colorScheme.onSurface;
    }

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
            isCallEntry
                ? value.toInt().toString()
                : '₹${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: (isNetSalary || isGrossSalary) ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
