class WrappedStats {
  final int totalCalls;
  final double totalHours;
  final DateTime? bestDayDate;
  final int bestDayCalls;
  final double averageCsat;
  final double averageCq;
  final double totalEarnings;
  final String advisorPersona;
  final String personaDescription;
  final String monthName;
  final int year;

  const WrappedStats({
    required this.totalCalls,
    required this.totalHours,
    this.bestDayDate,
    required this.bestDayCalls,
    required this.averageCsat,
    required this.averageCq,
    required this.totalEarnings,
    required this.advisorPersona,
    required this.personaDescription,
    required this.monthName,
    required this.year,
  });
}
