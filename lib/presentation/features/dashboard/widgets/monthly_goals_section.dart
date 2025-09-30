import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';

class MonthlyGoalsSection extends StatelessWidget {
  final MonthlySummary summary;
  const MonthlyGoalsSection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GoalsBloc, GoalsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final hoursProgress = (summary.totalLoginHours / state.targetHours).clamp(0.0, 1.0);
        final callsProgress = (summary.totalCalls / state.targetCalls).clamp(0.0, 1.0);

        final now = DateTime.now();
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

        // Check if an entry for today exists
        final hasTodayEntry = summary.entries.any((entry) =>
            entry.date.year == now.year &&
            entry.date.month == now.month &&
            entry.date.day == now.day);

        int remainingDays;
        if (hasTodayEntry) {
          remainingDays = lastDayOfMonth - now.day;
        } else {
          remainingDays = lastDayOfMonth - now.day + 1;
        }

        // Ensure remainingDays is not negative
        remainingDays = remainingDays.clamp(0, lastDayOfMonth);

        final remainingHours = (state.targetHours - summary.totalLoginHours).clamp(0.0, double.infinity);
        final dailyAvgHours = remainingDays > 0 ? remainingHours / remainingDays : remainingHours;

        final remainingCalls = (state.targetCalls - summary.totalCalls).clamp(0, double.infinity).toInt();
        final dailyAvgCalls = remainingDays > 0 ? (remainingCalls / remainingDays).ceil() : remainingCalls;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Goals', style: theme.textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () => _showEditGoalsDialog(context, state.targetHours, state.targetCalls),
                    icon: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                    label: Text('Edit', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              CustomCard(
                child: (hoursProgress >= 1.0 && callsProgress >= 1.0)
                    ? _buildGoalsComplete(context)
                    : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressIndicator(
                          context,
                          percent: hoursProgress,
                          title: 'Login Hours',
                          current: summary.totalLoginHours.toStringAsFixed(1),
                          target: '${state.targetHours}h',
                          color: theme.colorScheme.primary,
                        ),
                        _buildProgressIndicator(
                          context,
                          percent: callsProgress,
                          title: 'Calls',
                          current: summary.totalCalls.toString(),
                          target: state.targetCalls.toString(),
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    _buildGoalDetails(
                      context,
                      'Remaining Hours to Goal:',
                      '${remainingHours.toStringAsFixed(1)}h',
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      'Remaining Calls to Goal:',
                      '$remainingCalls',
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      'Daily Avg. Hours Needed:',
                      '${dailyAvgHours.toStringAsFixed(1)}h',
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      'Daily Avg. Calls Needed:',
                      '${dailyAvgCalls.toInt()}',
                    ),
                    _buildSalaryProjection(
                      context,
                      summary, // current summary
                      _calculateProjectedSummary(state, summary), // projected summary
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context, {
    required double percent,
    required String title,
    required String current,
    required String target,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 12.0,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(current, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Text('/ $target', style: theme.textTheme.bodySmall),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(title, style: theme.textTheme.titleMedium),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: color.withOpacity(0.2),
      progressColor: color,
      animation: true,
      animationDuration: 800,
    );
  }

  Widget _buildGoalDetails(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  MonthlySummary _calculateProjectedSummary(GoalsState goalsState, MonthlySummary currentSummary) {
    // Create a dummy list of entries that represents the goal achieved.
    // We can create a single entry with the total values.
    final projectedEntry = DailyEntry(
      date: DateTime.now(),
      callCount: goalsState.targetCalls,
      loginHours: goalsState.targetHours,
      loginMinutes: 0,
      loginSeconds: 0,
    );

    final projectedBaseSalary = goalsState.targetCalls * AppConstants.baseRatePerCall;

    return MonthlySummary(
      month: currentSummary.month,
      year: currentSummary.year,
      entries: [projectedEntry],
      csatSummary: currentSummary.csatSummary,
      cqSummary: currentSummary.cqSummary,
      loginDays: currentSummary.loginDays, // This might not be accurate for projection, but it's the best we have
      baseSalary: projectedBaseSalary,
    );
  }

  Widget _buildSalaryProjection(BuildContext context, MonthlySummary currentSummary, MonthlySummary projectedSummary) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        const SizedBox(height: 16),
        Text(
          'Salary Projection',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildSalaryRow(
          context,
          'Current Salary',
          '₹${currentSummary.netSalary.toStringAsFixed(2)}',
          Icons.trending_up,
          theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildSalaryRow(
          context,
          'Projected Salary (at 100% goal)',
          '₹${projectedSummary.netSalary.toStringAsFixed(2)}',
          Icons.military_tech,
          theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildSalaryRow(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(width: 8), // Add some space between label and value
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildGoalsComplete(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.6),
            theme.colorScheme.secondaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Congratulations!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You have successfully achieved your monthly goals.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditGoalsDialog(BuildContext context, int currentHours, int currentCalls) {
    final theme = Theme.of(context);
    final hoursController = TextEditingController(text: currentHours.toString());
    final callsController = TextEditingController(text: currentCalls.toString());
    final _formKey = GlobalKey<FormState>(); // Add a form key

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<GoalsBloc>(context),
          child: AlertDialog(
            title: const Text('Set Monthly Goals'),
            content: Form(
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Login Hours (Max 570)',
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      filled: theme.inputDecorationTheme.filled,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter target hours';
                      }
                      final hours = int.tryParse(value);
                      if (hours == null) {
                        return 'Please enter a valid number';
                      }
                      if (hours > 570) {
                        return 'Hours cannot exceed 570';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: callsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Call Count',
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      filled: theme.inputDecorationTheme.filled,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter target calls';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<GoalsBloc, GoalsState>(
                    listener: (context, state) {
                      if (state.suggestedHours != null && state.suggestedCalls != null) {
                        hoursController.text = state.suggestedHours.toString();
                        callsController.text = state.suggestedCalls.toString();
                      }
                    },
                    builder: (context, state) {
                      if (state.suggestionsLoading) {
                        return const CircularProgressIndicator();
                      }
                      return TextButton.icon(
                        onPressed: () {
                          context.read<GoalsBloc>().add(GetGoalSuggestions());
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Get AI Suggestions'),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) { // Validate the form
                    final newHours = int.tryParse(hoursController.text) ?? currentHours;
                    final newCalls = int.tryParse(callsController.text) ?? currentCalls;
                    context.read<GoalsBloc>().add(SaveGoals(hours: newHours, calls: newCalls));
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Save'),
              )
            ],
          ),
        );
      },
    );
  }
}
