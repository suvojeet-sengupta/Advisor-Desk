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
import 'package:advisor_desk/presentation/features/user/bloc/user_cubit.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class MonthlyGoalsSection extends StatelessWidget {
  final MonthlySummary summary;
  const MonthlyGoalsSection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = context.watch<LanguageCubit>().state;

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

        DailyEntry? todayEntry;
        try {
          todayEntry = summary.entries.firstWhere(
            (entry) =>
                entry.date.year == now.year &&
                entry.date.month == now.month &&
                entry.date.day == now.day,
          );
        } catch (e) {
          todayEntry = null;
        }

        final todaysHours = todayEntry?.totalLoginTimeInHours ?? 0.0;
        final todaysCalls = todayEntry?.callCount ?? 0;

        final isDailyHoursGoalCompleted = dailyAvgHours > 0 && todaysHours >= dailyAvgHours;
        final isDailyCallsGoalCompleted = dailyAvgCalls > 0 && todaysCalls >= dailyAvgCalls;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get(language, 'monthly_goals_title'), style: theme.textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () => _showEditGoalsDialog(context, state.targetHours, state.targetCalls),
                    icon: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                    label: Text(AppStrings.get(language, 'edit_btn'), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              CustomCard(
                child: (hoursProgress >= 1.0 && callsProgress >= 1.0)
                    ? _buildGoalsComplete(context, state, language)
                    : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressIndicator(
                          context,
                          percent: hoursProgress,
                          title: AppStrings.get(language, 'login_hours_label'),
                          current: summary.totalLoginHours.toStringAsFixed(1),
                          target: '${state.targetHours}h',
                          color: theme.colorScheme.primary,
                        ),
                        _buildProgressIndicator(
                          context,
                          percent: callsProgress,
                          title: AppStrings.get(language, 'calls_label'),
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
                      AppStrings.get(language, 'remaining_hours_goal'),
                      '${remainingHours.toStringAsFixed(1)}h',
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      AppStrings.get(language, 'remaining_calls_goal'),
                      '$remainingCalls',
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      AppStrings.get(language, 'daily_avg_hours_needed'),
                      todayEntry == null
                          ? '${dailyAvgHours.toStringAsFixed(1)}h'
                          : '${todaysHours.toStringAsFixed(1)}h / ${dailyAvgHours.toStringAsFixed(1)}h',
                      isCompleted: isDailyHoursGoalCompleted,
                    ),
                    const SizedBox(height: 8),
                    _buildGoalDetails(
                      context,
                      AppStrings.get(language, 'daily_avg_calls_needed'),
                      todayEntry == null
                          ? '${dailyAvgCalls.toInt()}'
                          : '${todaysCalls} / ${dailyAvgCalls.toInt()}',
                      isCompleted: isDailyCallsGoalCompleted,
                    ),
                    if (todayEntry != null)
                      const SizedBox(height: 8),
                    if (todayEntry != null)
                      _buildGoalDetails(
                        context,
                        AppStrings.get(language, 'remaining_calls_today'),
                        '${(dailyAvgCalls - todaysCalls).clamp(0, dailyAvgCalls).toInt()}',
                      ),
                    if (todayEntry != null)
                      const SizedBox(height: 8),
                    if (todayEntry != null)
                      _buildGoalDetails(
                        context,
                        AppStrings.get(language, 'remaining_hours_today'),
                        '${(dailyAvgHours - todaysHours).clamp(0, dailyAvgHours).toStringAsFixed(1)}h',
                      ),
                    _buildSalaryProjection(
                      context,
                      summary, // current summary
                      _calculateProjectedSummary(state, summary), // projected summary
                      language,
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

  Widget _buildGoalDetails(BuildContext context, String label, String value, {bool isCompleted = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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

  Widget _buildSalaryProjection(BuildContext context, MonthlySummary currentSummary, MonthlySummary projectedSummary, Language language) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        const SizedBox(height: 16),
        Text(
          AppStrings.get(language, 'salary_projection_title'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildSalaryRow(
          context,
          AppStrings.get(language, 'current_salary_label'),
          '₹${currentSummary.netSalary.toStringAsFixed(2)}',
          Icons.trending_up,
          theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildSalaryRow(
          context,
          AppStrings.get(language, 'projected_salary_label'),
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

  Widget _buildGoalsComplete(BuildContext context, GoalsState state, Language language) {
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
            AppStrings.get(language, 'congratulations_title'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get(language, 'goals_achieved_message'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showEditGoalsDialog(context, state.targetHours, state.targetCalls),
            icon: Icon(Icons.visibility, color: theme.colorScheme.onPrimaryContainer),
            label: Text(
              AppStrings.get(language, 'view_targets_btn'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    final language = context.read<LanguageCubit>().state; // Use context.read here since it's a callback

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<GoalsBloc>(context),
          child: AlertDialog(
            title: Text(AppStrings.get(language, 'set_monthly_goals_title')),
            content: Form(
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.get(language, 'target_login_hours_label'),
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      filled: theme.inputDecorationTheme.filled,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.get(language, 'enter_target_hours_error');
                      }
                      final hours = int.tryParse(value);
                      if (hours == null) {
                        return AppStrings.get(language, 'valid_number_error');
                      }
                      if (hours > 570) {
                        return AppStrings.get(language, 'hours_exceed_error');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: callsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.get(language, 'target_call_count_label'),
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      filled: theme.inputDecorationTheme.filled,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.get(language, 'enter_target_calls_error');
                      }
                      if (int.tryParse(value) == null) {
                        return AppStrings.get(language, 'valid_number_error');
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
                        label: Text(AppStrings.get(language, 'get_ai_suggestions_btn')),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppStrings.get(language, 'cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) { // Validate the form
                    final newHours = int.tryParse(hoursController.text) ?? currentHours;
                    final newCalls = int.tryParse(callsController.text) ?? currentCalls;
                    final userId = context.read<UserCubit>().state is UserLoaded
                        ? (context.read<UserCubit>().state as UserLoaded).currentUserId
                        : '1';
                    context.read<GoalsBloc>().add(SaveGoals(hours: newHours, calls: newCalls, userId: userId));
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(AppStrings.get(language, 'save_btn')),
              )
            ],
          ),
        );
      },
    );
  }
}
