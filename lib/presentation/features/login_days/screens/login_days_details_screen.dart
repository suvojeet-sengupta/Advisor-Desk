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
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class LoginDaysDetailsScreen extends StatelessWidget {
  final MonthlySummary summary;

  const LoginDaysDetailsScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Attendance & Login'),
      body: BlocBuilder<LoginDaysBloc, LoginDaysState>(
        builder: (context, state) {
          if (state is LoginDaysLoading || state is LoginDaysInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoginDaysError) {
            return Center(child: Text(state.message));
          }
          if (state is LoginDaysLoaded) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY STATISTICS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStats(context, state),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.formattedMonthYear.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.presentCount}/${DateTime(summary.year, summary.month + 1, 0).day} Days',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _buildCalendar(context, state),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                    child: CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LEGEND',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLegend(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  Widget _buildStats(BuildContext context, LoginDaysLoaded state) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Present', state.presentCount.toString(), Colors.green, Icons.check_circle_outline_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Absent', state.absentCount.toString(), Colors.red, Icons.highlight_off_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Leaves', (state.weekOffCount + state.personalLeaveCount).toString(), Colors.blue, Icons.event_note_rounded)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, LoginDaysLoaded state) {
    final theme = Theme.of(context);
    final month = summary.month;
    final year = summary.year;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;

    final loginDates = state.loginEntries.map((e) => e.date).toSet();
    final leaveEntries = {for (var e in state.leaveEntries) e.date: e};

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < firstDayWeekday - 1) {
            return const SizedBox.shrink();
          }
          final day = index - (firstDayWeekday - 1) + 1;
          final date = DateTime(year, month, day);
          final isLoginDay = loginDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
          final leaveEntry = leaveEntries[date];
          final isFutureDay = date.isAfter(DateTime.now());
          final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

          Color bgColor = theme.cardColor;
          Color textColor = theme.textTheme.bodyMedium!.color!;
          Color accentColor = Colors.transparent;
          IconData? statusIcon;

          if (isFutureDay) {
            bgColor = theme.disabledColor.withOpacity(0.05);
            textColor = theme.disabledColor;
          } else if (isLoginDay) {
            accentColor = Colors.green;
            bgColor = Colors.green.withOpacity(0.1);
            textColor = Colors.green;
            statusIcon = Icons.check_circle_rounded;
          } else if (leaveEntry != null) {
            if (leaveEntry.type == LeaveType.weekOff) {
              accentColor = Colors.blue;
              bgColor = Colors.blue.withOpacity(0.1);
              textColor = Colors.blue;
              statusIcon = Icons.weekend_rounded;
            } else {
              accentColor = Colors.orange;
              bgColor = Colors.orange.withOpacity(0.1);
              textColor = Colors.orange;
              statusIcon = Icons.person_rounded;
            }
          } else { // Absent day
            if (isToday) {
               accentColor = theme.colorScheme.primary;
               bgColor = theme.colorScheme.primary.withOpacity(0.1);
               textColor = theme.colorScheme.primary;
               statusIcon = Icons.pending_actions_rounded;
            } else {
              accentColor = Colors.red;
              bgColor = Colors.red.withOpacity(0.1);
              textColor = Colors.red;
              statusIcon = Icons.cancel_rounded;
            }
          }

          return GestureDetector(
            onTap: () => _showMarkDayDialog(context, date, isLoginDay, leaveEntry),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isToday ? theme.colorScheme.primary : accentColor.withOpacity(0.3),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isToday ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    DateFormat('E').format(date).toUpperCase().substring(0, 1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacity(0.6),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$day',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (statusIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(statusIcon, size: 10, color: textColor.withOpacity(0.8)),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: daysInMonth + (firstDayWeekday - 1),
      ),
    );
  }

  void _showMarkDayDialog(BuildContext context, DateTime date, bool isLoginDay, LeaveEntry? leaveEntry) {
    if (isLoginDay || date.isAfter(DateTime.now())) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark Status for ${DateFormat('dd MMM yyyy').format(date)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildActionTile(
                  context,
                  'Week Off',
                  'Standard weekly holiday',
                  Icons.weekend_rounded,
                  Colors.blue,
                  () {
                    context.read<LoginDaysBloc>().add(MarkDayAsLeave(LeaveEntry(date: date, type: LeaveType.weekOff)));
                    Navigator.pop(dialogContext);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  'Personal Leave',
                  'Sick leave or personal work',
                  Icons.person_rounded,
                  Colors.orange,
                  () {
                    context.read<LoginDaysBloc>().add(MarkDayAsLeave(LeaveEntry(date: date, type: LeaveType.personal)));
                    Navigator.pop(dialogContext);
                  },
                ),
                if (leaveEntry != null) ...[
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    'Mark as Absent',
                    'Reset to standard absent status',
                    Icons.cancel_rounded,
                    Colors.red,
                    () {
                      context.read<LoginDaysBloc>().add(DeleteLeave(date));
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: [
        _buildLegendItem(context, Colors.green, 'Present'),
        _buildLegendItem(context, Colors.red, 'Absent'),
        _buildLegendItem(context, Theme.of(context).colorScheme.primary, 'In Progress'),
        _buildLegendItem(context, Colors.blue, 'Week Off'),
        _buildLegendItem(context, Colors.orange, 'Personal'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}