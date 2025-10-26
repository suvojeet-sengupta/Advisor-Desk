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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectionCard(context, state),
                const SizedBox(height: 24),
                _buildControlsCard(context, state),
                const SizedBox(height: 24),
                _buildSalaryBreakdownCard(context, state),
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
      child: Column(
        children: [
          Text(
            'Projected Net Salary',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(state.projectedSummary!.netSalary),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'based on ${state.remainingWorkDays} remaining work days',
            style: theme.textTheme.bodySmall,
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
          Text('Adjust Your Projections', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSlider(
            context,
            label: 'Avg. Daily Calls',
            value: state.projectedDailyCalls,
            min: 0,
            max: 200,
            divisions: 200,
            onChanged: (value) {
              context.read<ForecasterBloc>().add(ProjectedValuesChanged(dailyCalls: value));
            },
          ),
          const SizedBox(height: 16),
          _buildSlider(
            context,
            label: 'Avg. Daily Hours',
            value: state.projectedDailyHours,
            min: 0,
            max: 12,
            divisions: 24,
            onChanged: (value) {
              context.read<ForecasterBloc>().add(ProjectedValuesChanged(dailyHours: value));
            },
          ),
           const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  onPressed: () {
                     context.read<ForecasterBloc>().add(SimulateDayOff(date: DateTime.now()));
                  },
                  child: const Text('Simulate Day Off'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedButton(
                  onPressed: () {
                    context.read<ForecasterBloc>().add(ResetSimulation());
                  },
                  child: const Text('Reset'),
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
      required ValueChanged<double> onChanged}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            Text(value.toStringAsFixed(1), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdownCard(BuildContext context, ForecasterState state) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final summary = state.projectedSummary!;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projected Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildBreakdownRow(context, 'Projected Total Calls', summary.totalCalls.toString()),
          _buildBreakdownRow(context, 'Base Salary', currencyFormat.format(summary.baseSalary)),
          _buildBreakdownRow(context, 'Bonus', currencyFormat.format(summary.bonusAmount), isAchieved: summary.isBonusAchieved),
          _buildBreakdownRow(context, 'CSAT Bonus', currencyFormat.format(summary.csatBonus), isAchieved: summary.isCSATBonusAchieved),
          const Divider(),
          _buildBreakdownRow(context, 'Gross Salary', currencyFormat.format(summary.totalSalary + summary.csatBonus)),
          _buildBreakdownRow(context, 'TDS Deduction', currencyFormat.format(summary.tdsDeduction)),
          const Divider(),
          _buildBreakdownRow(context, 'Net Salary', currencyFormat.format(summary.netSalary), isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, String title, String value, {bool? isAchieved, bool isHighlight = false}) {
    final theme = Theme.of(context);
    Color? statusColor;
    if (isAchieved != null) {
      statusColor = isAchieved ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal)),
              if (isAchieved != null) ...[
                const SizedBox(width: 8),
                Icon(isAchieved ? Icons.check_circle : Icons.cancel, color: statusColor, size: 16),
              ]
            ],
          ),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
