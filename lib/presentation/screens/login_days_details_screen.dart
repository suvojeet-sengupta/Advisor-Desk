
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_bloc.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_state.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_event.dart';

class LoginDaysDetailsScreen extends StatelessWidget {
  final MonthlySummary summary;

  const LoginDaysDetailsScreen({Key? key, required this.summary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login Activity'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<LoginDaysBloc, LoginDaysState>(
          builder: (context, state) {
            if (state is LoginDaysLoading || state is LoginDaysInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LoginDaysError) {
              return Center(child: Text(state.message));
            }
            if (state is LoginDaysLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.formattedMonthYear,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStats(context, state),
                    const SizedBox(height: 24),
                    _buildCalendar(context, state),
                    const SizedBox(height: 24),
                    _buildLegend(context),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  Widget _buildStats(BuildContext context, LoginDaysLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _StatCard(
          label: 'Present',
          value: state.presentCount.toString(),
          color: AppColors.present,
        ),
        _StatCard(
          label: 'Absent',
          value: state.absentCount.toString(),
          color: AppColors.absent,
        ),
        _StatCard(
          label: 'Week Off',
          value: state.weekOffCount.toString(),
          color: AppColors.weekOff,
        ),
        _StatCard(
          label: 'Personal',
          value: state.personalLeaveCount.toString(),
          color: AppColors.personalLeave,
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context, LoginDaysLoaded state) {
    final month = summary.month;
    final year = summary.year;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;

    final loginDates = state.loginEntries.map((e) => e.date).toSet();
    final leaveEntries = {for (var e in state.leaveEntries) e.date: e};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth + (firstDayWeekday - 1),
      itemBuilder: (context, index) {
        if (index < firstDayWeekday - 1) {
          return Container(); // Empty container for offset
        }
        final day = index - (firstDayWeekday - 1) + 1;
        final date = DateTime(year, month, day);
        final isLoginDay =
            loginDates.any((d) => DateUtils.isSameDay(d, date));
        final leaveEntry = leaveEntries[date];
        final isFutureDay = date.isAfter(DateTime.now());

        return _CalendarDay(
          date: date,
          isLoginDay: isLoginDay,
          leaveEntry: leaveEntry,
          isFutureDay: isFutureDay,
          onTap: () =>
              _showMarkDayDialog(context, date, isLoginDay, leaveEntry),
        );
      },
    );
  }

  void _showMarkDayDialog(
      BuildContext context, DateTime date, bool isLoginDay, LeaveEntry? leaveEntry) {
    if (isLoginDay || date.isAfter(DateTime.now())) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Mark Day Off',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Week Off',
                    style: TextStyle(color: AppColors.textSecondary)),
                onTap: () {
                  context.read<LoginDaysBloc>().add(
                      MarkDayAsLeave(LeaveEntry(date: date, type: LeaveType.weekOff)));
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Personal Leave',
                    style: TextStyle(color: AppColors.textSecondary)),
                onTap: () {
                  context.read<LoginDaysBloc>().add(MarkDayAsLeave(
                      LeaveEntry(date: date, type: LeaveType.personal)));
                  Navigator.pop(dialogContext);
                },
              ),
              if (leaveEntry != null)
                ListTile(
                  title: const Text('Mark as Absent',
                      style: TextStyle(color: AppColors.textSecondary)),
                  onTap: () {
                    context.read<LoginDaysBloc>().add(DeleteLeave(date));
                    Navigator.pop(dialogContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: const [
        _LegendItem(color: AppColors.present, label: 'Present'),
        _LegendItem(color: AppColors.absent, label: 'Absent'),
        _LegendItem(color: AppColors.weekOff, label: 'Week Off'),
        _LegendItem(color: AppColors.personalLeave, label: 'Personal'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {Key? key,
      required this.label,
      required this.value,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isLoginDay;
  final LeaveEntry? leaveEntry;
  final bool isFutureDay;
  final VoidCallback onTap;

  const _CalendarDay({
    Key? key,
    required this.date,
    required this.isLoginDay,
    this.leaveEntry,
    required this.isFutureDay,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;
    Widget? icon;

    if (isFutureDay) {
      bgColor = AppColors.futureDay.withOpacity(0.2);
      textColor = AppColors.futureDay;
    } else if (isLoginDay) {
      bgColor = AppColors.present.withOpacity(0.2);
      textColor = AppColors.present;
    } else if (leaveEntry != null) {
      if (leaveEntry!.type == LeaveType.weekOff) {
        bgColor = AppColors.weekOff.withOpacity(0.2);
        textColor = AppColors.weekOff;
        icon = Icon(Icons.weekend, size: 16, color: AppColors.weekOff);
      } else {
        bgColor = AppColors.personalLeave.withOpacity(0.2);
        textColor = AppColors.personalLeave;
        icon = Icon(Icons.person, size: 16, color: AppColors.personalLeave);
      }
    } else {
      bgColor = AppColors.absent.withOpacity(0.2);
      textColor = AppColors.absent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: textColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            if (icon != null)
              Positioned(
                top: 4,
                right: 4,
                child: icon,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
