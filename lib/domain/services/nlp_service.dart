import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';

class NlpService {
  // A simple NLP service using keyword matching.
  // A real-world app might use a more advanced NLP library or API.
  Future<AiInsight> processQuestion({
    required String question,
    required MonthlySummary summary,
  }) async {
    final lowerCaseQuestion = question.toLowerCase();

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

    return const AiInsight(message: "I'm sorry, I don't have the answer to that yet. I'm still learning!");
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
