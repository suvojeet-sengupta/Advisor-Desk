import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart'; // Ensure CustomAppBar is used if standard AppBar was there, or keep basic AppBar if it's a detail screen.
// Actually standard AppBar is fine for details but let's see if we can use CustomAppBar for consistency if available, standard AppBar matches previous code.
// Keeping standard AppBar for now to minimize navigation changes, but styling it.

class SalaryDetailsScreen extends StatelessWidget {
  final MonthlySummary summary;

  const SalaryDetailsScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Salary Breakdown'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
         // Depending on theme, might need specific color, assuming theme data handles appBarTheme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(context, currencyFormat),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'EARNINGS'),
            const SizedBox(height: 12),
            _buildEarningsCard(context, currencyFormat),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'DEDUCTIONS'),
            const SizedBox(height: 12),
            _buildDeductionsCard(context, currencyFormat),
            if (summary.customRateEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'CUSTOM RATE ADJUSTMENTS'),
              const SizedBox(height: 12),
              _buildCustomRateCard(context, currencyFormat),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, NumberFormat currencyFormat) {
    return CustomCard(
      padding: const EdgeInsets.all(32.0),
      // To give a hero feel, we could use a gradient container inside CustomCard if CustomCard supports it,
      // or just style the text heavily.
      // Let's rely on clean typography.
      child: Column(
        children: [
          Text(
            'NET SALARY',
             style: Theme.of(context).textTheme.labelMedium?.copyWith(
               color: Colors.grey,
               letterSpacing: 2.0,
               fontWeight: FontWeight.bold,
             ),
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormat.format(summary.netSalary),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                ),
          ),
           const SizedBox(height: 8),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(
               color: Colors.green.withOpacity(0.1),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               'Final Payout',
               style: Theme.of(context).textTheme.labelSmall?.copyWith(
                 color: Colors.green,
                 fontWeight: FontWeight.bold,
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, NumberFormat currencyFormat) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSalaryDetailRow(
            context,
            'Base Salary',
            currencyFormat.format(summary.salaryBreakdown['Base Salary'] ?? 0.0),
            Icons.account_balance_wallet_rounded,
            Colors.blue,
            isFirst: true,
          ),
          _buildDivider(context),
          _buildSalaryDetailRow(
            context,
            'Performance Bonus',
            currencyFormat.format(summary.salaryBreakdown['Bonus Amount'] ?? 0.0),
            Icons.trending_up_rounded,
            Colors.amber,
          ),
          _buildDivider(context),
          _buildSalaryDetailRow(
            context,
            'CSAT Incentives',
            currencyFormat.format(summary.salaryBreakdown['CSAT Bonus'] ?? 0.0),
            Icons.emoji_events_rounded,
            Colors.purple,
             isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(BuildContext context, NumberFormat currencyFormat) {
    final tdsDeduction = summary.salaryBreakdown['TDS Deduction'] ?? 0.0;
    
    // Check if there are any other deductions
    // For now based on existing code only TDS.
    
    if (tdsDeduction > 0) {
      return CustomCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildSalaryDetailRow(
              context,
              'TDS (Tax)',
              '- ${currencyFormat.format(tdsDeduction)}',
              Icons.account_balance_rounded,
              Colors.red,
              isFirst: true,
              isLast: true,
              valueColor: Colors.red,
            ),
          ],
        ),
      );
    } else {
      return CustomCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green.withOpacity(0.5), size: 48),
              const SizedBox(height: 12),
              Text(
                'No Deductions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCustomRateCard(BuildContext context, NumberFormat currencyFormat) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
             _buildSalaryDetailRow(
              context,
              'Total Custom Calls',
              summary.totalCustomRateCalls.toString(),
              Icons.call_rounded,
              Colors.teal,
               isFirst: true,
            ),
            if (summary.customRateEntries.isNotEmpty)
              _buildDivider(context),
            // Show only up to 5 entries to save space, or all? All is fine but let's make it compact.
            // Using a limit to avoid huge lists in detail screen if many entries.
             ...summary.customRateEntries.take(5).map((entry) {
                return Column(
                  children: [
                     _buildSalaryDetailRow(
                      context,
                      DateFormat('dd MMM').format(entry.date),
                      currencyFormat.format(entry.customCallRate),
                      Icons.calendar_today_rounded,
                      Colors.grey,
                      isCompact: true,
                    ),
                    if (entry != summary.customRateEntries.last && entry != summary.customRateEntries.take(5).last)
                       _buildDivider(context, indent: 56),
                  ],
                );
             }).toList(),
              if (summary.customRateEntries.length > 5)
                 Padding(
                   padding: const EdgeInsets.all(12.0),
                   child: Text(
                     '+ ${summary.customRateEntries.length - 5} more entries',
                     style: TextStyle(color: Colors.grey, fontSize: 12),
                   ),
                 ),
        ],
      ),
    );
  }

  Widget _buildSalaryDetailRow(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color, 
    {
      bool isFirst = false, 
      bool isLast = false,
      bool isCompact = false,
      Color? valueColor,
    }
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0, 
        vertical: isCompact ? 12.0 : 16.0
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isCompact ? 18 : 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title, 
               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                 fontWeight: isCompact ? FontWeight.normal : FontWeight.w500,
               ),
            ),
          ),
          Text(
            value, 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, {double indent = 20}) {
    return Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.05), indent: indent, endIndent: 20);
  }
}
