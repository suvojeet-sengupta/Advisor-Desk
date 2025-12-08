import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart'; // Keep if still using for other components
import 'package:advisor_desk/presentation/routes/app_router.dart';

class SalarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SalarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.salaryBreakdown;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.salaryDetailsRoute,
            arguments: summary,
          );
        },
        child: Container( // Changed from CustomCard to Container for custom gradient
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.9),
                theme.colorScheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // Consistent with DashboardCard
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Salary', // Directly show Net Salary as the main focus
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary, // Text on primary color
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₹${summary.netSalary.toStringAsFixed(2)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w900, // Even bolder
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 16),
              // Display a few key breakdown items within the same card
              _buildSalaryBreakdownRow(
                context,
                Icons.call_outlined,
                'Calls Bonus',
                '₹${breakdown['Bonus Amount']?.toStringAsFixed(2) ?? '0.00'}',
                theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              _buildSalaryBreakdownRow(
                context,
                Icons.star_outline,
                'CSAT Bonus',
                '₹${breakdown['CSAT Bonus']?.toStringAsFixed(2) ?? '0.00'}',
                theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              _buildSalaryBreakdownRow(
                context,
                Icons.remove_circle_outline,
                'TDS Deduction',
                '₹${breakdown['TDS Deduction']?.toStringAsFixed(2) ?? '0.00'}',
                theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onPrimary.withOpacity(0.6),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryBreakdownRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}