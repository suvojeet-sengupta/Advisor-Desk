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
          'Salary Details for ${summary.formattedMonthYear}',
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
              'Basic Salary',
              currencyFormat.format(summary.basicSalary),
              Icons.account_balance_wallet,
              Theme.of(context).colorScheme.secondary,
            ),
            const Divider(),
            _buildSalaryDetailRow(
              context,
              'Incentive',
              currencyFormat.format(summary.incentive),
              Icons.star,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard(BuildContext context, NumberFormat currencyFormat) {
    // Assuming there are no deductions in the summary for now.
    // If deductions are added in the future, they can be displayed here.
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