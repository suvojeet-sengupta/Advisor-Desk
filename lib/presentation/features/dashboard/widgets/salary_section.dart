import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class SalarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SalarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            _buildSalaryRow(
              context,
              'Base Salary',
              '₹${summary.baseSalary.toStringAsFixed(2)}',
              Icons.money,
              AppColors.accentBlue,
            ),
            _buildSalaryRow(
              context,
              'Bonus Amount',
              '₹${summary.bonusAmount.toStringAsFixed(2)}',
              Icons.card_giftcard,
              summary.isBonusAchieved ? AppColors.accentGreen : AppColors.accentRed,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48.0, bottom: 8.0),
              child: Text(
                summary.isBonusAchieved
                    ? '(Target Achieved: ${summary.totalCalls} calls / ${summary.totalLoginHours.toStringAsFixed(0)} hrs)'
                    : '(Target Not Met: ${summary.totalCalls} calls / ${summary.totalLoginHours.toStringAsFixed(0)} hrs)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: summary.isBonusAchieved ? AppColors.textSecondary : AppColors.accentRed,
                    ),
              ),
            ),
            _buildSalaryRow(
              context,
              'CSAT Bonus',
              '₹${summary.csatBonus.toStringAsFixed(2)}',
              Icons.star,
              summary.isCSATBonusAchieved ? AppColors.accentGreen : AppColors.accentRed,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48.0, bottom: 8.0),
              child: Text(
                summary.isCSATBonusAchieved
                    ? '(Target Achieved: ${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}% CSAT / ${summary.totalCalls} calls)'
                    : '(Target Not Met: ${summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}% CSAT / ${summary.totalCalls} calls)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: summary.isCSATBonusAchieved ? AppColors.textSecondary : AppColors.accentRed,
                    ),
              ),
            ),
            _buildSalaryRow(
              context,
              'Total Salary',
              '₹${summary.totalSalary.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              AppColors.dishTvOrange,
            ),
            _buildSalaryRow(
              context,
              'TDS Deduction',
              '₹${summary.tdsDeduction.toStringAsFixed(2)}',
              Icons.remove_circle,
              AppColors.accentRed,
            ),
            _buildSalaryRow(
              context,
              'Net Salary',
              '₹${summary.netSalary.toStringAsFixed(2)}',
              Icons.payments,
              AppColors.accentGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRow(
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
