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

  const LoginDaysDetailsScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login Activity'),
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
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.formattedMonthYear,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildStats(context, state),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: _buildCalendar(context, state),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildLegend(context),
                      ],
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, 'Present', state.presentCount.toString(), Colors.green),
        _buildStatItem(context, 'Absent', state.absentCount.toString(), Colors.red),
        if (state.inProgressCount > 0)
          _buildStatItem(context, 'In Progress', state.inProgressCount.toString(), Colors.grey),
        _buildStatItem(context, 'Week Off', state.weekOffCount.toString(), Colors.blue),
        _buildStatItem(context, 'Personal', state.personalLeaveCount.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < firstDayWeekday - 1) {
            return Container(); // Empty container for offset
          }
          final day = index - (firstDayWeekday - 1) + 1;
          final date = DateTime(year, month, day);
          final isLoginDay = loginDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
          final leaveEntry = leaveEntries[date];
          final isFutureDay = date.isAfter(DateTime.now());
          final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

          Color bgColor;
          Color textColor;
          Widget? icon;

          if (isFutureDay) {
            bgColor = theme.disabledColor.withOpacity(0.1);
            textColor = theme.disabledColor;
          } else if (isLoginDay) {
            bgColor = Colors.green.withOpacity(0.2);
            textColor = Colors.green;
          } else if (leaveEntry != null) {
            if (leaveEntry.type == LeaveType.weekOff) {
              bgColor = Colors.blue.withOpacity(0.2);
              textColor = Colors.blue;
              icon = Icon(Icons.weekend, size: 16, color: Colors.blue);
            } else {
              bgColor = Colors.orange.withOpacity(0.2);
              textColor = Colors.orange;
              icon = Icon(Icons.person, size: 16, color: Colors.orange);
            }
          } else { // Absent day
            if (isToday) {
              bgColor = Colors.grey.withOpacity(0.2);
              textColor = Colors.grey;
            } else {
              bgColor = Colors.red.withOpacity(0.2);
              textColor = Colors.red;
            }
          }

          return GestureDetector(
            onTap: () => _showMarkDayDialog(context, date, isLoginDay, leaveEntry),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isToday && !isLoginDay && leaveEntry == null)
                        Text(
                          'In Progress',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$day',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ]
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
        },
        childCount: daysInMonth + (firstDayWeekday - 1),
      ),
    );
  }

  void _showMarkDayDialog(BuildContext context, DateTime date, bool isLoginDay, LeaveEntry? leaveEntry) {
    if (isLoginDay) {
      // Cannot mark a login day as leave
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Mark Day Off'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Week Off'),
                onTap: () {
                  context.read<LoginDaysBloc>().add(MarkDayAsLeave(LeaveEntry(date: date, type: LeaveType.weekOff)));
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Personal Leave'),
                onTap: () {
                  // You can add a text field here to get a reason
                  context.read<LoginDaysBloc>().add(MarkDayAsLeave(LeaveEntry(date: date, type: LeaveType.personal)));
                  Navigator.pop(dialogContext);
                },
              ),
              if (leaveEntry != null)
                ListTile(
                  title: const Text('Mark as Absent'),
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
      children: [
        _buildLegendItem(context, Colors.green, 'Present'),
        _buildLegendItem(context, Colors.red, 'Absent'),
        _buildLegendItem(context, Colors.grey, 'In Progress'),
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
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}