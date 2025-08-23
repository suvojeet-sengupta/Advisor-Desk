import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class SalarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SalarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.salaryBreakdown;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...breakdown.entries.map((entry) {
              return _buildSalaryRow(
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

  Widget _buildSalaryRow(
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
        iconColor = summary.isBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
        break;
      case 'CSAT Bonus':
        icon = Icons.star;
        iconColor = summary.isCSATBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
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