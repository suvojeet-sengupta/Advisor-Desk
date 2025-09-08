import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

class AiInsightService {
  String getInsight({
    required MonthlySummary summary,
    required GoalsState goals,
    required Profile profile,
  }) {
    final now = DateTime.now();
    final hour = now.hour;

    // Try to find today's and yesterday's entry
    DailyEntry? todayEntry;
    try {
      todayEntry = summary.entries.firstWhere((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day);
    } catch (e) {
      todayEntry = null;
    }

    final yesterday = now.subtract(const Duration(days: 1));
    DailyEntry? yesterdayEntry;
    try {
      yesterdayEntry = summary.entries.firstWhere((e) =>
          e.date.year == yesterday.year &&
          e.date.month == yesterday.month &&
          e.date.day == yesterday.day);
    } catch (e) {
      yesterdayEntry = null;
    }

    // Priority 1: Morning Briefing (if no entry for today yet)
    if (hour >= 5 && hour < 12 && todayEntry == null) {
      return _getMorningBriefing(summary, goals, profile, yesterdayEntry);
    }

    // Priority 2: End-of-Day Summary (if there is an entry for today)
    if (hour >= 17 && todayEntry != null) {
      return _getEndOfDaySummary(profile, todayEntry, summary, goals);
    }
    
    // Priority 3: Weekly Review (on Sunday or Monday)
    if (now.weekday == DateTime.monday || now.weekday == DateTime.sunday) {
        // For simplicity, we'll just show a generic weekly message.
        // A real implementation would need to fetch last week's data.
        return "It's the start of a new week, ${profile.name ?? 'User'}! Let's set some great goals and make it a productive one.";
    }

    // Fallback: Generic pacing alert or tip
    return _getGenericPacingAlert(summary, goals, profile);
  }

  String _getMorningBriefing(MonthlySummary summary, GoalsState goals, Profile profile, DailyEntry? yesterdayEntry) {
    final name = profile.name != null ? ", ${profile.name}" : "";
    
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (lastDayOfMonth - now.day + 1).clamp(1, 31);
    
    final remainingCalls = (goals.targetCalls - summary.totalCalls).clamp(0, goals.targetCalls);
    final dailyAvgCallsNeeded = (remainingCalls / remainingDays).ceil();

    String briefing = "Good morning${name}! To meet your monthly goal, you need to average about $dailyAvgCallsNeeded calls per day.";

    if (yesterdayEntry != null) {
      briefing += " Yesterday you made ${yesterdayEntry.callCount} calls. Keep up the great work!";
    } else {
      briefing += " Let's make today a great start!";
    }
    return briefing;
  }

  String _getEndOfDaySummary(Profile profile, DailyEntry todayEntry, MonthlySummary summary, GoalsState goals) {
    final name = profile.name != null ? " ${profile.name}" : "";
    final dailyAvgNeeded = (goals.targetCalls / DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day).ceil();
    final difference = todayEntry.callCount - dailyAvgNeeded;

    String summaryText = "Great work today${name}! You logged ${todayEntry.formattedLoginTime} and made ${todayEntry.callCount} calls.";

    if (difference >= 0) {
      summaryText += " That's ${difference} calls more than your daily average goal. You're on the right track!";
    } else {
      summaryText += " You're a bit behind the daily average, but you can catch up tomorrow!";
    }
    
    summaryText += " Your projected net salary for the month is now ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(summary.netSalary)}.";
    return summaryText;
  }

  String _getGenericPacingAlert(MonthlySummary summary, GoalsState goals, Profile profile) {
    final name = profile.name != null ? ", ${profile.name}" : "";
    final progress = (summary.totalCalls / goals.targetCalls * 100).clamp(0, 100);
    return "Hello${name}! You've completed ${progress.toStringAsFixed(0)}% of your monthly call target. Keep pushing!";
  }
}
