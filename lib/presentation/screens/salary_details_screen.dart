import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';

class SalaryDetailsScreen extends StatelessWidget {
  final MonthlySummary summary;

  const SalaryDetailsScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Salary Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, currencyFormat),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Earnings'),
            const SizedBox(height: 8),
            _buildEarningsCard(context, currencyFormat),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Deductions'),
            const SizedBox(height: 8),
            _buildDeductionsCard(context, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NumberFormat currencyFormat) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Net Salary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(summary.netSalary),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEarningsCard(BuildContext context, NumberFormat currencyFormat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSalaryDetailRow(
              context,
              'Base Salary',
              currencyFormat.format(summary.salaryBreakdown['Base Salary'] ?? 0.0),
              Icons.account_balance_wallet,
              Theme.of(context).colorScheme.secondary,
            ),
            const Divider(),
            _buildSalaryDetailRow(
              context,
              'Bonus Amount',
              currencyFormat.format(summary.salaryBreakdown['Bonus Amount'] ?? 0.0),
              Icons.star,
              Colors.amber,
            ),
            const Divider(),
            _buildSalaryDetailRow(
              context,
              'CSAT Bonus',
              currencyFormat.format(summary.salaryBreakdown['CSAT Bonus'] ?? 0.0),
              Icons.emoji_events,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard(BuildContext context, NumberFormat currencyFormat) {
    final tdsDeduction = summary.salaryBreakdown['TDS Deduction'] ?? 0.0;
    if (tdsDeduction > 0) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSalaryDetailRow(
                context,
                'TDS Deduction',
                currencyFormat.format(tdsDeduction),
                Icons.money_off,
                Colors.red,
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No deductions for this month.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
  }

  Widget _buildSalaryDetailRow(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
