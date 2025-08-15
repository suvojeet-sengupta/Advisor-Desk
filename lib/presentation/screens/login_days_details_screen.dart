import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';

class LoginDaysDetailsScreen extends StatelessWidget {
  final MonthlySummary summary;

  const LoginDaysDetailsScreen({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginDates = summary.entries.map((e) => e.date).toSet();
    final month = summary.month;
    final year = summary.year;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);

    // Adjust for Dart's weekday format (Monday=1, Sunday=7)
    final firstDayWeekday = firstDayOfMonth.weekday;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Login Activity'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.formattedMonthYear,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildCalendar(context, year, month, daysInMonth, firstDayWeekday, loginDates),
            const SizedBox(height: 24),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, int year, int month, int daysInMonth, int firstDayWeekday, Set<DateTime> loginDates) {
    final theme = Theme.of(context);
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) => Text(day, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))).toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
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
            final isLoginDay = loginDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
            final isFutureDay = date.isAfter(DateTime.now());

            Color bgColor;
            Color textColor;

            if (isFutureDay) {
              bgColor = theme.disabledColor.withOpacity(0.1);
              textColor = theme.disabledColor;
            } else if (isLoginDay) {
              bgColor = Colors.green.withOpacity(0.2);
              textColor = Colors.green;
            } else { // Absent day
              bgColor = Colors.red.withOpacity(0.2);
              textColor = Colors.red;
            }

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, Colors.green, 'Login Day'),
        const SizedBox(width: 24),
        _buildLegendItem(context, Colors.red, 'Absent Day'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
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
