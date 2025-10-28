import 'package:advisor_desk/domain/services/query_models.dart';

class QueryParser {
  Query parse(String question) {
    final lowerCaseQuestion = question.toLowerCase();

    // Date parsing (more flexible)
    DateTime? targetDate = _parseTargetDate(lowerCaseQuestion);

    // Bonus related queries
    if (lowerCaseQuestion.contains('bonus')) {
      return Query(type: QueryType.bonusInfo, targetDate: targetDate);
    }

    // CSAT related queries
    if (lowerCaseQuestion.contains('csat')) {
      if (lowerCaseQuestion.contains('worst' ) || lowerCaseQuestion.contains('lowest')) {
        return Query(type: QueryType.worstCsatDays, targetDate: targetDate);
      }
      return Query(type: QueryType.csatScore, targetDate: targetDate);
    }

    // CQ related queries
    if (lowerCaseQuestion.contains('cq')) {
      return Query(type: QueryType.cqScore, targetDate: targetDate);
    }

    // Total calls queries
    if (lowerCaseQuestion.contains('total calls') || lowerCaseQuestion.contains('calls')) {
      return Query(type: QueryType.totalCalls, targetDate: targetDate);
    }

    // Total login hours queries
    if (lowerCaseQuestion.contains('total login hours') || lowerCaseQuestion.contains('login hours')) {
      return Query(type: QueryType.totalLoginHours, targetDate: targetDate);
    }

    // Comparison queries (basic example)
    if (lowerCaseQuestion.contains('compare') || lowerCaseQuestion.contains('vs')) {
      if (lowerCaseQuestion.contains('calls')) {
        return Query(type: QueryType.comparison, metric: Metric.calls, comparisonType: ComparisonType.currentVsPreviousMonth, targetDate: targetDate);
      }
      // Add more comparison types as needed
    }

    return Query(type: QueryType.unknown);
  }

  DateTime? _parseTargetDate(String question) {
    final now = DateTime.now();
    if (question.contains('last month')) {
      return DateTime(now.year, now.month - 1, 1);
    } else if (question.contains('this month')) {
      return DateTime(now.year, now.month, 1);
    } else if (question.contains('last week')) {
      return now.subtract(const Duration(days: 7));
    } else if (question.contains('yesterday')) {
      return now.subtract(const Duration(days: 1));
    } else if (question.contains('today')) {
      return now;
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
}
