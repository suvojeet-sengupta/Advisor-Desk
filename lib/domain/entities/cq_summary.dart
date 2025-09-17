// Call Quality (CQ) Summary Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

/// Represents a summary of Call Quality (CQ) for a specific month.
///
/// This class aggregates a list of [CQEntry] objects for a given month and year,
/// and provides calculated properties such as the monthly average CQ score and
/// the total number of audits.
class CQSummary extends Equatable {
  /// The list of CQ entries for the month.
  final List<CQEntry> entries;
  /// The month of the summary (1-12).
  final int month;
  /// The year of the summary.
  final int year;
  
  /// Creates a new instance of [CQSummary].
  ///
  /// The [entries], [month], and [year] are required.
  const CQSummary({
    required this.entries,
    required this.month,
    required this.year,
  });
  
  /// Calculates the monthly average CQ percentage.
  double get monthlyAverageCQ {
    if (entries.isEmpty) return 0.0;
    
    double totalPercentage = entries.fold(0.0, (sum, entry) => sum + entry.percentage);
    return totalPercentage / entries.length;
  }
  
  /// The total number of audits for the month.
  int get totalAudits {
    return entries.length;
  }
  
  /// Determines if the monthly CQ score indicates a need for improvement (below 85%).
  bool get needsImprovement {
    return monthlyAverageCQ < 85.0;
  }
  
  /// Returns a descriptive quality rating based on the average percentage.
  String get qualityRating {
    if (entries.isEmpty) return 'No Audits';
    if (monthlyAverageCQ >= 85) return 'Quality Met';
    return 'Quality Not Met';
  }
  
  /// Returns a formatted string for the month and year (e.g., "January 2023").
  String get formattedMonthYear {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  /// The average CQ score for the month.
  double get averageScore {
    return monthlyAverageCQ;
  }
  
  @override
  List<Object?> get props => [entries, month, year];
}
