import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/query_parser.dart';
import 'package:advisor_desk/domain/services/query_models.dart';

class NlpService {
  final PerformanceRepository _performanceRepository;
  final QueryParser _queryParser;

  NlpService({required PerformanceRepository performanceRepository})
      : _performanceRepository = performanceRepository,
        _queryParser = QueryParser();

  Future<AiInsight> processQuestion({
    required String question,
  }) async {
    final parsedQuery = _queryParser.parse(question);
    final targetDate = parsedQuery.targetDate ?? DateTime.now();
    final summary = await _performanceRepository.getMonthlySummary(targetDate.month, targetDate.year);

    switch (parsedQuery.type) {
      case QueryType.bonusInfo:
        return _handleBonusQuestion(summary);
      case QueryType.worstCsatDays:
        return _handleWorstCsatDays(summary);
      case QueryType.csatScore:
        return _handleCsatScoreQuestion(summary);
      case QueryType.cqScore:
        return _handleCqScoreQuestion(summary);
      case QueryType.totalCalls:
        return _handleTotalCallsQuestion(summary);
      case QueryType.totalLoginHours:
        return _handleTotalLoginHoursQuestion(summary);
      case QueryType.comparison:
        return _handleComparisonQuery(parsedQuery, summary);
      case QueryType.trend:
        // TODO: Implement trend analysis
        return const AiInsight(message: "Trend analysis is not yet supported.");
      case QueryType.unknown:
      default:
        return const AiInsight(message: "I'm sorry, I don't have the answer to that yet. I'm still learning!");
    }
  }

  AiInsight _handleTotalCallsQuestion(MonthlySummary summary) {
    return AiInsight(message: "Your total calls for ${summary.formattedMonthYear} were ${summary.totalCalls}.");
  }

  AiInsight _handleTotalLoginHoursQuestion(MonthlySummary summary) {
    return AiInsight(message: "Your total login hours for ${summary.formattedMonthYear} were ${summary.totalLoginHours.toStringAsFixed(1)}.");
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

  Future<AiInsight> _handleComparisonQuery(Query query, MonthlySummary currentSummary) async {
    if (query.metric == null || query.comparisonType == null) {
      return const AiInsight(message: "I need more information to perform a comparison.");
    }

    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previousSummary = await _performanceRepository.getMonthlySummary(previousMonth.month, previousMonth.year);

    String response = "";

    switch (query.metric) {
      case Metric.calls:
        final currentCalls = currentSummary.totalCalls;
        final previousCalls = previousSummary.totalCalls;
        response = "This month you made $currentCalls calls. Last month you made $previousCalls calls. ";
        if (currentCalls > previousCalls) {
          response += "That's ${currentCalls - previousCalls} more calls than last month!";
        } else if (currentCalls < previousCalls) {
          response += "That's ${previousCalls - currentCalls} fewer calls than last month.";
        } else {
          response += "That's the same number of calls as last month.";
        }
        break;
      case Metric.loginHours:
        final currentHours = currentSummary.totalLoginHours;
        final previousHours = previousSummary.totalLoginHours;
        response = "This month you logged ${currentHours.toStringAsFixed(1)} hours. Last month you logged ${previousHours.toStringAsFixed(1)} hours. ";
        if (currentHours > previousHours) {
          response += "That's ${(currentHours - previousHours).toStringAsFixed(1)} more hours than last month!";
        } else if (currentHours < previousHours) {
          response += "That's ${(previousHours - currentHours).toStringAsFixed(1)} fewer hours than last month.";
        } else {
          response += "That's the same number of hours as last month.";
        }
        break;
      case Metric.csat:
        final currentCsat = currentSummary.csatSummary?.monthlyCSATPercentage ?? 0.0;
        final previousCsat = previousSummary.csatSummary?.monthlyCSATPercentage ?? 0.0;
        response = "This month your CSAT score is ${currentCsat.toStringAsFixed(2)}%. Last month it was ${previousCsat.toStringAsFixed(2)}%. ";
        if (currentCsat > previousCsat) {
          response += "You improved your CSAT by ${(currentCsat - previousCsat).toStringAsFixed(2)}%!";
        } else if (currentCsat < previousCsat) {
          response += "Your CSAT decreased by ${(previousCsat - currentCsat).toStringAsFixed(2)}% compared to last month.";
        } else {
          response += "Your CSAT score is consistent with last month.";
        }
        break;
      case Metric.cq:
        final currentCq = currentSummary.cqSummary?.monthlyAverageCQ ?? 0.0;
        final previousCq = previousSummary.cqSummary?.monthlyAverageCQ ?? 0.0;
        response = "This month your CQ score is ${currentCq.toStringAsFixed(2)}%. Last month it was ${previousCq.toStringAsFixed(2)}%. ";
        if (currentCq > previousCq) {
          response += "You improved your CQ by ${(currentCq - previousCq).toStringAsFixed(2)}%!";
        } else if (currentCq < previousCq) {
          response += "Your CQ decreased by ${(previousCq - currentCq).toStringAsFixed(2)}% compared to last month.";
        } else {
          response += "Your CQ score is consistent with last month.";
        }
        break;
      default:
        response = "I can't compare that metric yet.";
    }
    return AiInsight(message: response);
  }
}

