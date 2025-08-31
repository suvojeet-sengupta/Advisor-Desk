import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

class ReportSummary extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyEntry> entries;
  final CSATSummary? csatSummary;
  final CQSummary? cqSummary;

  const ReportSummary({
    required this.startDate,
    required this.endDate,
    required this.entries,
    this.csatSummary,
    this.cqSummary,
  });

  // Total login hours for the period
  double get totalLoginHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.totalLoginTimeInHours);
  }

  // Total calls for the period
  int get totalCalls {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.callCount);
  }

  // Total billable calls for the period
  int get billableCalls {
    return totalCalls;
  }

  // Average daily login hours
  double get averageDailyLoginHours {
    if (entries.isEmpty) return 0;
    return totalLoginHours / entries.length;
  }

  // Average daily calls
  double get averageDailyCalls {
    if (entries.isEmpty) return 0;
    return totalCalls / entries.length;
  }

  // Check if bonus targets are achieved
  bool get isBonusAchieved {
    return totalCalls >= AppConstants.bonusCallTarget &&
           totalLoginHours >= AppConstants.bonusHourTarget;
  }

  // Calculate base salary (₹4.30 per call)
  double get baseSalary {
    return billableCalls * AppConstants.baseRatePerCall;
  }

  // Calculate bonus amount (₹2000 if targets are met)
  double get bonusAmount {
    return isBonusAchieved ? AppConstants.bonusAmount : 0;
  }

  // Calculate total salary
  double get totalSalary {
    return baseSalary + bonusAmount;
  }

  // Calculate CSAT bonus
  double get csatBonus {
    if (isCSATBonusAchieved) {
      return totalSalary * AppConstants.csatBonusRate;
    }
    return 0.0;
  }

  // Check if CSAT bonus targets are achieved
  bool get isCSATBonusAchieved {
    return csatSummary != null &&
           csatSummary!.monthlyCSATPercentage >= AppConstants.csatBonusPercentage &&
           totalCalls >= AppConstants.csatBonusCallTarget;
  }

  // Calculate TDS deduction
  double get tdsDeduction {
    return (totalSalary + csatBonus) * AppConstants.tdsRate;
  }

  // Calculate net salary
  double get netSalary {
    return totalSalary + csatBonus - tdsDeduction;
  }

  // Detailed salary breakdown
  Map<String, double> get salaryBreakdown {
    return {
      'Total Calls': totalCalls.toDouble(),
      'Base Salary': baseSalary,
      'Bonus Amount': bonusAmount,
      'CSAT Bonus': csatBonus,
      'Gross Salary': totalSalary + csatBonus,
      'TDS Deduction': tdsDeduction,
      'Net Salary': netSalary,
    };
  }

  // Format as Date Range (e.g., "Jan 01 - Jan 31, 2025")
  String get formattedDateRange {
    final start = '${startDate.day} ${_getMonthAbbreviation(startDate.month)}';
    final end = '${endDate.day} ${_getMonthAbbreviation(endDate.month)}, ${endDate.year}';
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${_getMonthAbbreviation(startDate.month)} ${startDate.day} - ${endDate.day}, ${endDate.year}';
    } else if (startDate.year == endDate.year) {
      return '${_getMonthAbbreviation(startDate.month)} ${startDate.day} - ${endDate.day} ${_getMonthAbbreviation(endDate.month)}, ${endDate.year}';
    } else {
      return '${_getMonthAbbreviation(startDate.month)} ${startDate.day}, ${startDate.year} - ${endDate.day} ${_getMonthAbbreviation(endDate.month)}, ${endDate.year}';
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [startDate, endDate, entries, csatSummary, cqSummary];
}
