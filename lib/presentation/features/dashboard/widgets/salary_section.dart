import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SalarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.salaryBreakdown;
    final language = context.watch<LanguageCubit>().state;

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
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(language, 'salary_details_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...breakdown.entries.map((entry) {
                return _buildSalaryRow(
                  context,
                  entry.key,
                  entry.value,
                  language,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryRow(
    BuildContext context,
    String title,
    double value,
    Language language,
  ) {
    final isCallEntry = title.toLowerCase().contains('calls');
    final isNetSalary = title.toLowerCase().contains('net salary');
    final isGrossSalary = title.toLowerCase().contains('gross salary');

    IconData icon;
    Color iconColor;
    String localizedTitle = title;

    // Map existing keys to localized strings
    switch (title) {
      case 'Total Calls':
        icon = Icons.call;
        iconColor = Theme.of(context).colorScheme.secondary;
        localizedTitle = AppStrings.get(language, 'total_calls_card');
        break;
      case 'Non-billable Calls':
        icon = Icons.phone_disabled;
        iconColor = Theme.of(context).colorScheme.error;
        localizedTitle = AppStrings.get(language, 'non_billable_calls_card');
        break;
      case 'Billable Calls':
        icon = Icons.phone_in_talk;
        iconColor = Colors.green;
        localizedTitle = AppStrings.get(language, 'billable_calls_label');
        break;
      case 'Base Salary':
        icon = Icons.money;
        iconColor = Theme.of(context).colorScheme.secondary;
        localizedTitle = AppStrings.get(language, 'base_salary_label');
        break;
      case 'Bonus Amount':
        icon = Icons.card_giftcard;
        iconColor = summary.isBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
        localizedTitle = AppStrings.get(language, 'bonus_amount_label');
        break;
      case 'CSAT Bonus':
        icon = Icons.star;
        iconColor = summary.isCSATBonusAchieved ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
        localizedTitle = AppStrings.get(language, 'csat_bonus_label');
        break;
      case 'Gross Salary':
        icon = Icons.account_balance_wallet;
        iconColor = Theme.of(context).colorScheme.primary;
        localizedTitle = AppStrings.get(language, 'gross_salary_label');
        break;
      case 'TDS Deduction':
        icon = Icons.remove_circle;
        iconColor = Theme.of(context).colorScheme.error;
        localizedTitle = AppStrings.get(language, 'tds_deduction_label');
        break;
      case 'Net Salary':
        icon = Icons.payments;
        iconColor = Theme.of(context).colorScheme.tertiary;
        localizedTitle = AppStrings.get(language, 'net_salary_card');
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
              localizedTitle,
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