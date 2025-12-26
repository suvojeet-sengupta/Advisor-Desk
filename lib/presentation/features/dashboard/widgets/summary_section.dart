import 'package:flutter/material.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SummarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SummarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(language, 'monthly_summary_title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'total_calls_card'),
              summary.totalCalls.toString(),
              Icons.call,
              Theme.of(context).colorScheme.primary,
            ),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'non_billable_calls_card'),
              summary.totalNonBillableCalls.toString(),
              Icons.phone_disabled,
              Theme.of(context).colorScheme.error,
            ),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'billable_calls_label'),
              summary.billableCalls.toString(),
              Icons.phone_in_talk,
              Colors.green,
            ),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'total_login_hours_card'),
              '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
              Icons.timer,
              Theme.of(context).colorScheme.secondary,
            ),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'average_daily_login_hours'),
              '${summary.averageDailyLoginHours.toStringAsFixed(2)} Hrs',
              Icons.access_time,
              Theme.of(context).colorScheme.tertiary,
            ),
            _buildSummaryRow(
              context,
              AppStrings.get(language, 'average_daily_calls'),
              summary.averageDailyCalls.toStringAsFixed(0),
              Icons.phone,
              Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
