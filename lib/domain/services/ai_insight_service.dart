import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

class AiInsightService {
  AiInsight getInsight({
    required MonthlySummary summary,
    required GoalsState goals,
    required Profile profile,
  }) {
    // First, check if there is any data to analyze.
    if (summary.totalCalls == 0 && summary.totalLoginHours == 0) {
      return AiInsight(
        message: "I'm ready to help, but I don't have any data for this month yet. Add your first entry to get started!",
        buttonText: "Add Entry",
        navigationRoute: AppRouter.addEntryRoute,
      );
    }

    final now = DateTime.now();
    final hour = now.hour;

    // Priority 0: Check if goals are set
    if (!goals.isGoalsSet) {
      return AiInsight(
        message: "You haven't set your personal goals for the month yet. Setting goals can help you stay motivated!",
        buttonText: "Set Goals Now",
        // This will trigger the dialog on the dashboard
        navigationRoute: 'show_goals_dialog',
      );
    }

    // Priority 1: Goal Analysis Insights
    final goalInsight = _getGoalAnalysisInsight(summary, goals);
    if (goalInsight != null) {
      return goalInsight;
    }

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

    // Priority 2: Morning Briefing (if no entry for today yet)
    if (hour >= 5 && hour < 12 && todayEntry == null) {
      return _getMorningBriefing(summary, goals, profile, yesterdayEntry);
    }

    // Priority 3: End-of-Day Summary (if there is an entry for today)
    if (hour >= 17 && todayEntry != null) {
      return _getEndOfDaySummary(profile, todayEntry, summary, goals);
    }

    // Priority 4: Anomaly Detection
    final anomalyInsight = _getAnomalyDetectionInsight(summary, profile);
    if (anomalyInsight != null) {
      return anomalyInsight;
    }
    
    // Priority 5: Weekly Review (on Sunday or Monday)
    if (now.weekday == DateTime.monday || now.weekday == DateTime.sunday) {
        return AiInsight(
          message: "It's the start of a new week, ${profile.name ?? 'User'}! Let's set some great goals and make it a productive one."
        );
    }

    // Fallback: Generic pacing alert or tip
    return _getGenericPacingAlert(summary, goals, profile);
  }

  AiInsight _getMorningBriefing(MonthlySummary summary, GoalsState goals, Profile profile, DailyEntry? yesterdayEntry) {
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
    return AiInsight(message: briefing);
  }

  AiInsight _getEndOfDaySummary(Profile profile, DailyEntry todayEntry, MonthlySummary summary, GoalsState goals) {
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
    return AiInsight(message: summaryText);
  }

  AiInsight? _getGoalAnalysisInsight(MonthlySummary summary, GoalsState goals) {
    final bool callTargetMet = summary.totalCalls >= goals.targetCalls;
    final bool hourTargetMet = summary.totalLoginHours >= goals.targetHours;

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (lastDayOfMonth - now.day + 1).clamp(0, 31);

    // If goals are met, provide positive reinforcement
    if (callTargetMet && hourTargetMet) {
      return AiInsight(message: "Amazing work! You've achieved both your call and login hour targets for the month! Keep up the excellent performance.");
    }

    // If close to a target but not met
    final callProgress = summary.totalCalls / goals.targetCalls;
    final hourProgress = summary.totalLoginHours / goals.targetHours;

    if (callProgress >= 0.9 && !callTargetMet) {
      final remainingCalls = goals.targetCalls - summary.totalCalls;
      return AiInsight(message: "You're almost there! Just $remainingCalls more calls to hit your monthly target. Keep up the great momentum!");
    }
    if (hourProgress >= 0.9 && !hourTargetMet) {
      final remainingHours = (goals.targetHours - summary.totalLoginHours).toStringAsFixed(1);
      return AiInsight(message: "You're very close to your login hours target! Just $remainingHours more hours to go. A final push will get you there!");
    }

    // If falling behind significantly
    if (remainingDays > 0) {
      final callsNeeded = (goals.targetCalls - summary.totalCalls).clamp(0, goals.targetCalls);
      final hoursNeeded = (goals.targetHours - summary.totalLoginHours).clamp(0.0, goals.targetHours.toDouble());

      final dailyCallsNeeded = (callsNeeded / remainingDays).ceil();
      final dailyHoursNeeded = (hoursNeeded / remainingDays).toStringAsFixed(1);

      if (callProgress < 0.7 && summary.totalCalls < goals.targetCalls) {
        return AiInsight(message: "Your call volume is a bit behind schedule. To meet your goal, you need to average about $dailyCallsNeeded calls per day for the rest of the month. Let's focus on increasing your outreach!");
      }
      if (hourProgress < 0.7 && summary.totalLoginHours < goals.targetHours) {
        return AiInsight(message: "You're falling behind on your login hours. To hit your target, aim for $dailyHoursNeeded hours per day for the remaining days. Consistent effort will make a difference!");
      }
    }

    return null; // No specific goal insight
  }

  AiInsight _getGenericPacingAlert(MonthlySummary summary, GoalsState goals, Profile profile) {
    final name = profile.name != null ? ", ${profile.name}" : "";
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;

    // Calculate expected progress based on current day of the month
    final expectedCallProgress = (currentDay / daysInMonth);
    final expectedHourProgress = (currentDay / daysInMonth);

    final actualCallProgress = summary.totalCalls / goals.targetCalls;
    final actualHourProgress = summary.totalLoginHours / goals.targetHours;

    String message = "Hello${name}!";

    if (actualCallProgress < expectedCallProgress * 0.8) { // More than 20% behind expected call progress
      message += " Your call volume seems a bit low for this point in the month. Consider increasing your daily outreach to stay on track with your goals.";
    } else if (actualHourProgress < expectedHourProgress * 0.8) { // More than 20% behind expected hour progress
      message += " Your login hours are a bit behind schedule. Try to be more consistent with your daily login to meet your monthly target.";
    } else if (actualCallProgress > expectedCallProgress * 1.2 && actualHourProgress > expectedHourProgress * 1.2) { // More than 20% ahead
      message += " You're well ahead of schedule on both calls and hours! Keep up the fantastic momentum, you're set for a great month!";
    } else {
      message += " You're making good progress towards your monthly goals. Keep up the consistent effort!";
    }

    return AiInsight(message: message);
  }

  AiInsight? _getAnomalyDetectionInsight(MonthlySummary summary, Profile profile) {
    final name = profile.name ?? 'User';
    final now = DateTime.now();

    // Get last 7 days of entries (excluding today if it's not complete)
    final recentEntries = summary.entries.where((e) =>
        e.date.isAfter(now.subtract(const Duration(days: 8))) &&
        e.date.isBefore(now.subtract(const Duration(days: 0))) // Exclude today for average calculation
    ).toList();

    if (recentEntries.length < 3) { // Need at least 3 days for a meaningful average
      return null;
    }

    final double avgRecentCalls = recentEntries.map((e) => e.callCount).reduce((a, b) => a + b) / recentEntries.length;
    final double avgRecentHours = recentEntries.map((e) => (e.loginHours * 60) + e.loginMinutes + (e.loginSeconds / 60)).reduce((a, b) => a + b) / recentEntries.length;

    // Get today's entry
    DailyEntry? todayEntry;
    try {
      todayEntry = summary.entries.firstWhere((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day);
    } catch (e) {
      todayEntry = null;
    }

    if (todayEntry != null) {
      // Check for significant drop in calls
      if (todayEntry.callCount < avgRecentCalls * 0.5) { // If today's calls are less than 50% of recent average
        return AiInsight(
          message: "Hey $name! Your call count today (${todayEntry.callCount}) is significantly lower than your recent daily average (${avgRecentCalls.toStringAsFixed(0)}). Is everything okay? Let's try to pick up the pace!",
          buttonText: "View Daily Entries",
          navigationRoute: AppRouter.monthlyDataRoute,
          navigationArguments: {
            'month': now.month,
            'year': now.year,
          },
        );
      }

      // Check for significant drop in hours
      if (((todayEntry.loginHours * 60) + todayEntry.loginMinutes + (todayEntry.loginSeconds / 60)) < avgRecentHours * 0.5) { // If today's hours are less than 50% of recent average
        return AiInsight(
          message: "Hi $name! Your login hours today (${todayEntry.formattedLoginTime}) are quite a bit lower than your recent daily average (${Duration(minutes: avgRecentHours.round()).toString().split('.').first}). Make sure you're logging your time accurately!",
          buttonText: "View Daily Entries",
          navigationRoute: AppRouter.monthlyDataRoute,
          navigationArguments: {
            'month': now.month,
            'year': now.year,
          },
        );
      }
    }

    return null;
  }

  AiInsight getAnalyzerInsight({
    required MonthlySummary summary,
    required CSATSummary csatSummary,
    required CQSummary cqSummary,
    required GoalsState goals,
    required Profile profile,
  }) {
    // First, check if there is any data to analyze.
    if (summary.totalCalls == 0 && summary.totalLoginHours == 0) {
      return AiInsight(
        message: "I don't have any performance data to analyze for this month yet. "
                 "Once you add your daily entries, I can provide a detailed breakdown of your performance, including calls, login hours, CSAT, and CQ scores. "
                 "Let's get some data in!",
      );
    }

    final name = profile.name ?? 'Advisor';
    final month = summary.monthName;

    final insights = <String>[];

    // Overall Summary
    insights.add(
        'Here is a summary of your performance for $month, $name.');

    // Call Performance
    final callProgress = (summary.totalCalls / goals.targetCalls * 100).toStringAsFixed(0);
    insights.add(
        'You have completed $callProgress% of your monthly call target (${summary.totalCalls}/${goals.targetCalls}).');
    if (summary.totalCalls > goals.targetCalls) {
      insights.add('Excellent work on exceeding your call target!');
    } else {
      final remainingCalls = goals.targetCalls - summary.totalCalls;
      final remainingDays = DateTime(summary.year, summary.month + 1, 0).day - DateTime.now().day;
      if (remainingDays > 0) {
        final callsPerDay = (remainingCalls / remainingDays).ceil();
        insights.add(
            'To meet your goal, you need to average about $callsPerDay calls per day for the rest of the month.');
      }
    }

    // Login Hour Performance
    final hourProgress = (summary.totalLoginHours / goals.targetHours * 100).toStringAsFixed(0);
    insights.add(
        'You have completed $hourProgress% of your monthly login hour target (${summary.totalLoginHours.toStringAsFixed(2)}/${goals.targetHours}).');
    if (summary.totalLoginHours > goals.targetHours) {
      insights.add('Great job on exceeding your login hour target!');
    }

    // CSAT Performance
    insights.add(
        'Your CSAT score for the month is ${csatSummary.monthlyCSATPercentage.toStringAsFixed(2)}%.');
    if (csatSummary.needsImprovement) {
      insights.add(
          'Your CSAT score is below the target. Consider focusing on improving customer satisfaction.');
    } else {
      insights.add('You are doing a great job in maintaining a good CSAT score.');
    }

    // CQ Performance
    insights.add(
        'Your average CQ score for the month is ${cqSummary.monthlyAverageCQ.toStringAsFixed(2)}%.');
    if (cqSummary.needsImprovement) {
      insights.add(
          'Your CQ score is below the target. It would be beneficial to review the call quality guidelines.');
    } else {
      insights.add('Excellent work on meeting call quality standards!');
    }

    // Salary
    final netSalary = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(summary.netSalary);
    insights.add('Your projected net salary for the month is $netSalary.');

    return AiInsight(message: insights.join('\n\n'));
  }
}