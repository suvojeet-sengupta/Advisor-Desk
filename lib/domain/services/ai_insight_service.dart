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
    final now = DateTime.now();
    final hour = now.hour;

    // Priority 0: Check if goals are set
    if (goals.targetCalls == 1000 && goals.targetHours == 150) { // Default values
      return const AiInsight(
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
    
    // Priority 4: Weekly Review (on Sunday or Monday)
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

  AiInsight _getGenericPacingAlert(MonthlySummary summary, GoalsState goals, Profile profile) {
    final name = profile.name != null ? ", ${profile.name}" : "";
    final progress = (summary.totalCalls / goals.targetCalls * 100).clamp(0, 100);
    return AiInsight(message: "Hello${name}! You've completed ${progress.toStringAsFixed(0)}% of your monthly call target. Keep pushing!");
  }

  AiInsight? _getGoalAnalysisInsight(MonthlySummary summary, GoalsState goals) {
    final bool callTargetMet = summary.totalCalls >= goals.targetCalls;
    final bool hourTargetMet = summary.totalLoginHours >= goals.targetHours;

    if (callTargetMet && !hourTargetMet) {
      final remainingHours = (goals.targetHours - summary.totalLoginHours).clamp(0, goals.targetHours);
      return AiInsight(message: "Congratulations! You've hit your call target of ${goals.targetCalls} for the month! Your next milestone is the login hours target. You are currently at ${summary.totalLoginHours.toStringAsFixed(1)} out of ${goals.targetHours} hours.");
    }

    if (!callTargetMet && hourTargetMet) {
      final remainingCalls = (goals.targetCalls - summary.totalCalls).clamp(0, goals.targetCalls);
      return AiInsight(message: "Congratulations! You've achieved your login hours target of ${goals.targetHours} for the month! Your next milestone is the call target. You need $remainingCalls more calls to reach it.");
    }

    if (callTargetMet && hourTargetMet) {
      return const AiInsight(message: "Amazing work! You've achieved both your call and login hour targets for the month!");
    }

    // If user is close to a target
    final callProgress = summary.totalCalls / goals.targetCalls;
    if (callProgress >= 0.9 && !callTargetMet) {
      final remainingCalls = goals.targetCalls - summary.totalCalls;
      return AiInsight(message: "You're almost there! Just $remainingCalls more calls to hit your monthly target. Keep up the great momentum!");
    }

    return null; // No specific goal insight
  }

  AiInsight getAnalyzerInsight({
    required MonthlySummary summary,
    required CSATSummary csatSummary,
    required CQSummary cqSummary,
    required GoalsState goals,
    required Profile profile,
  }) {
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