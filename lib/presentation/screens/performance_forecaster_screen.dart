import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';
import 'package:advisor_desk/presentation/features/performance_forecaster/bloc/forecaster_bloc.dart';
import 'package:advisor_desk/presentation/features/performance_forecaster/bloc/forecaster_event.dart';
import 'package:advisor_desk/presentation/features/performance_forecaster/bloc/forecaster_state.dart';

class PerformanceForecasterScreen extends StatelessWidget {
  final MonthlySummary summary;

  const PerformanceForecasterScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForecasterBloc(
        leaveRepository: context.read<LeaveRepository>(),
      )..add(InitializeForecaster(currentSummary: summary)),
      child: const PerformanceForecasterView(),
    );
  }
}

class PerformanceForecasterView extends StatelessWidget {
  const PerformanceForecasterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Performance Forecaster'),
      body: BlocBuilder<ForecasterBloc, ForecasterState>(
        builder: (context, state) {
          if (state.status == ForecasterStatus.loading || state.status == ForecasterStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ForecasterStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'An error occurred.'));
          }
          if (state.projectedSummary == null) {
            return const Center(child: Text('Could not load forecast data.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectionCard(context, state),
                const SizedBox(height: 24),
                Text(
                  'ADJUST PROJECTIONS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildControlsCard(context, state),
                const SizedBox(height: 24),
                 Text(
                  'PROJECTED BREAKDOWN',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSalaryBreakdownCard(context, state),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectionCard(BuildContext context, ForecasterState state) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'PROJECTED NET SALARY',
            style: theme.textTheme.labelMedium?.copyWith(
               color: Colors.grey,
               letterSpacing: 1.2,
               fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(state.projectedSummary!.netSalary),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: theme.colorScheme.surface,
               borderRadius: BorderRadius.circular(20),
               border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
             ),
             child: Text(
              '${state.remainingWorkDays} work days remaining',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context, ForecasterState state) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider(
            context,
            label: 'Avg. Daily Calls',
            value: state.projectedDailyCalls,
            min: 0,
            max: 200,
            divisions: 200,
            icon: Icons.call,
            onChanged: (value) {
              context.read<ForecasterBloc>().add(ProjectedValuesChanged(dailyCalls: value));
            },
          ),
          const SizedBox(height: 24),
          _buildSlider(
            context,
            label: 'Avg. Login Hours',
            value: state.projectedDailyHours,
            min: 0,
            max: 12,
            divisions: 24,
             icon: Icons.timer,
            onChanged: (value) {
              context.read<ForecasterBloc>().add(ProjectedValuesChanged(dailyHours: value));
            },
          ),
           const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  onPressed: () {
                     context.read<ForecasterBloc>().add(SimulateDayOff(date: DateTime.now()));
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                   // TODO: Fix AnimatedButton generic argument type if needed, passing text style manually
                  child: Text(
                     'Simulate Day Off', 
                     style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedButton(
                  onPressed: () {
                    context.read<ForecasterBloc>().add(ResetSimulation());
                  },
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  child: const Text('Reset', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
      {required String label,
      required double value,
      required double min,
      required double max,
      required int divisions,
      required IconData icon,
      required ValueChanged<double> onChanged}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           children: [
             Icon(icon, size: 18, color: Colors.grey),
             const SizedBox(width: 8),
             Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
             const Spacer(),
             Text(value.toStringAsFixed(1), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
           ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdownCard(BuildContext context, ForecasterState state) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final summary = state.projectedSummary!;

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
           _buildBreakdownRow(context, 'Projected Calls', summary.totalCalls.toString(), icon: Icons.call),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'Projected Hours', '${summary.totalLoginHours.toStringAsFixed(1)}h', icon: Icons.timer),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'Base Salary', currencyFormat.format(summary.baseSalary), icon: Icons.money),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'Bonus', currencyFormat.format(summary.bonusAmount), isAchieved: summary.isBonusAchieved, icon: Icons.star_border),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'CSAT Bonus', currencyFormat.format(summary.csatBonus), isAchieved: summary.isCSATBonusAchieved, icon: Icons.sentiment_satisfied),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'Gross Salary', currencyFormat.format(summary.totalSalary + summary.csatBonus), icon: Icons.account_balance_wallet),
           Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          _buildBreakdownRow(context, 'TDS Deduction', currencyFormat.format(summary.tdsDeduction), isPayment: false, icon: Icons.remove_circle_outline),
           // Net Salary is already in hero card, so skipping here or can be added as footer
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, String title, String value, {bool? isAchieved, bool isPayment = true, IconData? icon}) {
    final theme = Theme.of(context);
    Color valueColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    
    if (isAchieved != null) {
       valueColor = isAchieved ? Colors.green : Colors.red;
    } else if (!isPayment) {
       valueColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (icon != null) ...[
             Icon(icon, size: 18, color: Colors.grey),
             const SizedBox(width: 12),
          ],
          Text(title, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
           if (isAchieved != null) ...[
                const SizedBox(width: 8),
                Icon(isAchieved ? Icons.check_circle : Icons.cancel, color: isAchieved ? Colors.green : Colors.red, size: 16),
           ]
        ],
      ),
    );
  }
}
