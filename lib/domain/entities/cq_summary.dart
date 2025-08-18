// Call Quality (CQ) Summary Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

class CQSummary extends Equatable {
  final List<CQEntry> entries;
  final int month;
  final int year;
  
  const CQSummary({
    required this.entries,
    required this.month,
    required this.year,
  });
  
  // Calculate monthly average CQ percentage
  double get monthlyAverageCQ {
    if (entries.isEmpty) return 0.0;
    
    double totalPercentage = entries.fold(0.0, (sum, entry) => sum + entry.percentage);
    return totalPercentage / entries.length;
  }
  
  // Get total number of audits for the month
  int get totalAudits {
    return entries.length;
  }
  
  // Check if monthly CQ needs improvement (below 85%)
  bool get needsImprovement {
    return monthlyAverageCQ < 85.0;
  }
  
  // Get quality rating based on average percentage
  String get qualityRating {
    if (entries.isEmpty) return 'No Audits';
    if (monthlyAverageCQ >= 85) return 'Quality Met';
    return 'Quality Not Met';
  }
  
  // Get formatted month year
  String get formattedMonthYear {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  // Get average CQ score
  double get averageScore {
    return monthlyAverageCQ;
  }
  
  @override
  List<Object?> get props => [entries, month, year];
}


