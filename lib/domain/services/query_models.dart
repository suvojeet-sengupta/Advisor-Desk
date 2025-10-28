enum QueryType {
  totalCalls,
  totalLoginHours,
  csatScore,
  cqScore,
  bonusInfo,
  worstCsatDays,
  comparison,
  trend,
  unknown,
}

enum Metric {
  calls,
  loginHours,
  csat,
  cq,
  salary,
}

enum ComparisonType {
  currentVsPreviousMonth,
  highest,
  lowest,
}

class Query {
  final QueryType type;
  final Metric? metric;
  final DateTime? targetDate;
  final ComparisonType? comparisonType;
  final int? periodInMonths; // For trend analysis

  Query({
    required this.type,
    this.metric,
    this.targetDate,
    this.comparisonType,
    this.periodInMonths,
  });
}
