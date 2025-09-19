import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

class MonthlySummary extends Equatable {
  final int month;
  final int year;
  final List<DailyEntry> entries;
  final CSATSummary? csatSummary;
  final CQSummary? cqSummary; // Add CQSummary field
  final int loginDays;
  final int nonBillableCalls;
  final double baseSalary;
  
  const MonthlySummary({
    required this.month,
    required this.year,
    required this.entries,
    this.csatSummary,
    this.cqSummary, // Make it optional for now, will be populated later
    required this.loginDays,
    this.nonBillableCalls = 0,
    required this.baseSalary,
  });
  
  // Total login hours for the month
  double get totalLoginHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.totalLoginTimeInHours);
  }
  
  // Total calls for the month
  int get totalCalls {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.callCount);
  }

  // Total non-billable calls for the month
  int get totalNonBillableCalls {
    return nonBillableCalls;
  }

  // Total billable calls for the month
  int get billableCalls {
    return totalCalls - totalNonBillableCalls;
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
      'Non-billable Calls': totalNonBillableCalls.toDouble(),
      'Billable Calls': billableCalls.toDouble(),
      'Base Salary': baseSalary,
      'Bonus Amount': bonusAmount,
      'CSAT Bonus': csatBonus,
      'Gross Salary': totalSalary + csatBonus,
      'TDS Deduction': tdsDeduction,
      'Net Salary': netSalary,
    };
  }

  // Calculate average salary
  double get averageSalary {
    if (entries.isEmpty) return 0.0;
    return totalSalary / entries.length;
  }
  
  // Format month name
  String get monthName {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
  
  // Format as Month Year (e.g., "June 2025")
  String get formattedMonthYear {
    return '$monthName $year';
  }
  
  @override
  List<Object?> get props => [month, year, entries, csatSummary, cqSummary, nonBillableCalls, baseSalary];
}

