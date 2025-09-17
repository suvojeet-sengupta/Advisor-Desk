// CSAT Summary Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

/// Represents a summary of Customer Satisfaction (CSAT) for a specific month.
///
/// This class aggregates a list of [CSATEntry] objects for a given month and year,
/// and provides calculated properties such as total survey counts and the
/// overall monthly CSAT percentage.
class CSATSummary extends Equatable {
  /// The list of CSAT entries for the month.
  final List<CSATEntry> entries;
  /// The month of the summary (1-12).
  final int month;
  /// The year of the summary.
  final int year;
  
  /// Creates a new instance of [CSATSummary].
  ///
  /// The [entries], [month], and [year] are required.
  const CSATSummary({
    required this.entries,
    required this.month,
    required this.year,
  });
  
  /// The total count of "Top 2" (positive) responses for the month.
  int get totalT2Count {
    return entries.fold(0, (sum, entry) => sum + entry.t2Count);
  }
  
  /// The total count of "Bottom 2" (negative) responses for the month.
  int get totalB2Count {
    return entries.fold(0, (sum, entry) => sum + entry.b2Count);
  }
  
  /// The total count of "Neutral" responses for the month.
  int get totalNCount {
    return entries.fold(0, (sum, entry) => sum + entry.nCount);
  }
  
  /// The total number of survey responses for the month.
  int get totalSurveyHits {
    return totalT2Count + totalB2Count + totalNCount;
  }
  
  /// The overall CSAT percentage for the month, calculated as (T2% - B2%).
  double get monthlyCSATPercentage {
    if (totalSurveyHits == 0) return 0.0;
    
    return (totalT2Count - totalB2Count) / totalSurveyHits * 100;
  }
  
  /// Determines if the monthly CSAT score indicates a need for improvement (below 60%).
  bool get needsImprovement {
    return monthlyCSATPercentage < 60.0;
  }
  
  /// Returns a formatted string for the month and year (e.g., "January 2023").
  String get formattedMonthYear {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }
  
  /// The average of the daily CSAT percentages.
  double get averageScore {
    if (entries.isEmpty) return 0.0;
    
    double totalCSAT = entries.fold(0.0, (sum, entry) => sum + entry.csatPercentage);
    return totalCSAT / entries.length;
  }
  
  @override
  List<Object?> get props => [entries, month, year];
}
