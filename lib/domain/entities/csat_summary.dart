// CSAT Summary Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

class CSATSummary extends Equatable {
  final List<CSATEntry> entries;
  final int month;
  final int year;
  
  const CSATSummary({
    required this.entries,
    required this.month,
    required this.year,
  });
  
  // Calculate total counts for the month
  int get totalT2Count {
    return entries.fold(0, (sum, entry) => sum + entry.t2Count);
  }
  
  int get totalB2Count {
    return entries.fold(0, (sum, entry) => sum + entry.b2Count);
  }
  
  int get totalNCount {
    return entries.fold(0, (sum, entry) => sum + entry.nCount);
  }
  
  int get totalSurveyHits {
    return totalT2Count + totalB2Count + totalNCount;
  }
  
  // Calculate monthly CSAT percentage
  double get monthlyCSATPercentage {
    if (totalSurveyHits == 0) return 0.0;
    
    double t2Score = (100 / totalSurveyHits) * totalT2Count;
    double b2Score = (100 / totalSurveyHits) * totalB2Count;
    
    return t2Score - b2Score;
  }
  
  // Check if monthly CSAT needs improvement
  bool get needsImprovement {
    return monthlyCSATPercentage < 60.0;
  }
  
  // Get formatted month year
  String get formattedMonthYear {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }
  
  // Get average daily CSAT
  double get averageScore {
    if (entries.isEmpty) return 0.0;
    
    double totalCSAT = entries.fold(0.0, (sum, entry) => sum + entry.csatPercentage);
    return totalCSAT / entries.length;
  }
  
  @override
  List<Object?> get props => [entries, month, year];
}


