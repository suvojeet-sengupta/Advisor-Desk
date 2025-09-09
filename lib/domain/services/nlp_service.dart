import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';

import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class NlpService {
  final PerformanceRepository _performanceRepository;

  NlpService({required PerformanceRepository performanceRepository})
      : _performanceRepository = performanceRepository;
  Future<AiInsight> processQuestion({
    required String question,
  }) async {
    final lowerCaseQuestion = question.toLowerCase();
    final targetDate = _parseTargetDate(lowerCaseQuestion);
    final summary = await _performanceRepository.getMonthlySummary(targetDate.month, targetDate.year);

    if (lowerCaseQuestion.contains('bonus')) {
      return _handleBonusQuestion(summary);
    }

    if (lowerCaseQuestion.contains('csat') && (lowerCaseQuestion.contains('worst') || lowerCaseQuestion.contains('lowest'))) {
      return _handleWorstCsatDays(summary);
    }

    if (lowerCaseQuestion.contains('csat')) {
      return _handleCsatScoreQuestion(summary);
    }

    if (lowerCaseQuestion.contains('cq')) {
      return _handleCqScoreQuestion(summary);
    }

    if (lowerCaseQuestion.contains('total calls') || lowerCaseQuestion.contains('calls')) {
      return _handleTotalCallsQuestion(summary);
    }

    if (lowerCaseQuestion.contains('total login hours') || lowerCaseQuestion.contains('login hours')) {
      return _handleTotalLoginHoursQuestion(summary);
    }

    return const AiInsight(message: "I'm sorry, I don't have the answer to that yet. I'm still learning!");
  }

  AiInsight _handleTotalCallsQuestion(MonthlySummary summary) {
    return AiInsight(message: "Your total calls for ${summary.formattedMonthYear} were ${summary.totalCalls}.");
  }

  AiInsight _handleTotalLoginHoursQuestion(MonthlySummary summary) {
    return AiInsight(message: "Your total login hours for ${summary.formattedMonthYear} were ${summary.totalLoginHours.toStringAsFixed(1)}.");
  }

  DateTime _parseTargetDate(String question) {
    final now = DateTime.now();
    if (question.contains('last month')) {
      return DateTime(now.year, now.month - 1, 1);
    } else if (question.contains('january')) {
      return DateTime(now.year, 1, 1);
    } else if (question.contains('february')) {
      return DateTime(now.year, 2, 1);
    } else if (question.contains('march')) {
      return DateTime(now.year, 3, 1);
    } else if (question.contains('april')) {
      return DateTime(now.year, 4, 1);
    } else if (question.contains('may')) {
      return DateTime(now.year, 5, 1);
    } else if (question.contains('june')) {
      return DateTime(now.year, 6, 1);
    } else if (question.contains('july')) {
      return DateTime(now.year, 7, 1);
    } else if (question.contains('august')) {
      return DateTime(now.year, 8, 1);
    } else if (question.contains('september')) {
      return DateTime(now.year, 9, 1);
    } else if (question.contains('october')) {
      return DateTime(now.year, 10, 1);
    } else if (question.contains('november')) {
      return DateTime(now.year, 11, 1);
    } else if (question.contains('december')) {
      return DateTime(now.year, 12, 1);
    }
    // Default to current month if no specific month is mentioned
    return now;
  }

  AiInsight _handleCqScoreQuestion(MonthlySummary summary) {
    if (summary.cqSummary == null || summary.cqSummary!.monthlyAverageCQ == 0) {
      return const AiInsight(message: "I couldn't find your CQ score for this month. Make sure you have recorded your CQ data.");
    }

    final score = summary.cqSummary!.monthlyAverageCQ.toStringAsFixed(2);
    return AiInsight(message: "Your average CQ score for this month is $score%.");
  }

  AiInsight _handleCsatScoreQuestion(MonthlySummary summary) {
    if (summary.csatSummary == null || summary.csatSummary!.monthlyCSATPercentage == 0) {
      return const AiInsight(message: "I couldn't find your CSAT score for this month. Make sure you have recorded your CSAT data.");
    }

    final score = summary.csatSummary!.monthlyCSATPercentage.toStringAsFixed(2);
    return AiInsight(message: "Your average CSAT score for this month is $score%.");
  }

  AiInsight _handleBonusQuestion(MonthlySummary summary) {
    final callsNeeded = (AppConstants.bonusCallTarget - summary.totalCalls).clamp(0, AppConstants.bonusCallTarget);
    final hoursNeeded = (AppConstants.bonusHourTarget - summary.totalLoginHours).clamp(0.0, AppConstants.bonusHourTarget.toDouble());

    if (summary.isBonusAchieved) {
      return const AiInsight(message: "You have already achieved your bonus for this month. Great job!");
    }

    String response = "To get your bonus of ₹${AppConstants.bonusAmount}, you need to achieve ${AppConstants.bonusCallTarget} calls and ${AppConstants.bonusHourTarget} login hours.\n";
    response += "You still need $callsNeeded more calls and ${hoursNeeded.toStringAsFixed(1)} more hours.";

    return AiInsight(message: response);
  }

  AiInsight _handleWorstCsatDays(MonthlySummary summary) {
    if (summary.csatSummary == null || summary.csatSummary!.entries.isEmpty) {
      return const AiInsight(message: "There are no CSAT entries for this month to analyze.");
    }

    List<CSATEntry> sortedEntries = List.from(summary.csatSummary!.entries);
    sortedEntries.sort((a, b) => a.csatPercentage.compareTo(b.csatPercentage));

    final worstDays = sortedEntries.take(3).toList();

    if (worstDays.isEmpty) {
      return const AiInsight(message: "I couldn't find any specific CSAT days with low scores. Everything looks good!");
    }

    String response = "Here are the days with the lowest CSAT scores this month:\n";
    for (var entry in worstDays) {
      final date = DateFormat('MMM dd').format(entry.date);
      final score = entry.csatPercentage.toStringAsFixed(1);
      response += "- $date: $score%\n";
    }

    return AiInsight(message: response);
  }
}
