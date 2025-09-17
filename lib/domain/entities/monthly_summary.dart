import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

/// Represents a comprehensive summary of performance for a specific month.
///
/// This class aggregates daily entries, CSAT summaries, and CQ summaries to
/// provide a complete picture of the user's performance and calculates various
/// metrics, including salary details.
class MonthlySummary extends Equatable {
  /// The month of the summary (1-12).
  final int month;
  /// The year of the summary.
  final int year;
  /// The list of daily performance entries for the month.
  final List<DailyEntry> entries;
  /// The CSAT summary for the month.
  final CSATSummary? csatSummary;
  /// The CQ summary for the month.
  final CQSummary? cqSummary;
  /// The number of days the user logged in during the month.
  final int loginDays;
  /// The number of non-billable calls for the month.
  final int nonBillableCalls;
  
  /// Creates a new instance of [MonthlySummary].
  const MonthlySummary({
    required this.month,
    required this.year,
    required this.entries,
    this.csatSummary,
    this.cqSummary,
    required this.loginDays,
    this.nonBillableCalls = 0,
  });
  
  /// The total login hours for the month.
  double get totalLoginHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.totalLoginTimeInHours);
  }
  
  /// The total number of calls made in the month.
  int get totalCalls {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.callCount);
  }

  /// The total number of non-billable calls for the month.
  int get totalNonBillableCalls {
    return nonBillableCalls;
  }

  /// The total number of billable calls for the month.
  int get billableCalls {
    return totalCalls - totalNonBillableCalls;
  }

  /// The average number of login hours per day.
  double get averageDailyLoginHours {
    if (entries.isEmpty) return 0;
    return totalLoginHours / entries.length;
  }
  
  /// The average number of calls made per day.
  double get averageDailyCalls {
    if (entries.isEmpty) return 0;
    return totalCalls / entries.length;
  }
  
  /// Determines if the bonus targets for calls and hours have been achieved.
  bool get isBonusAchieved {
    return totalCalls >= AppConstants.bonusCallTarget && 
           totalLoginHours >= AppConstants.bonusHourTarget;
  }
  
  /// The base salary, calculated from the number of billable calls.
  double get baseSalary {
    return billableCalls * AppConstants.baseRatePerCall;
  }
  
  /// The bonus amount. Returns the full bonus if targets are met, otherwise 0.
  double get bonusAmount {
    return isBonusAchieved ? AppConstants.bonusAmount : 0;
  }
  
  /// The total salary before any bonuses or deductions.
  double get totalSalary {
    return baseSalary + bonusAmount;
  }

  /// The CSAT bonus amount.
  double get csatBonus {
    if (isCSATBonusAchieved) {
      return totalSalary * AppConstants.csatBonusRate;
    }
    return 0.0;
  }

  /// Determines if the CSAT bonus targets have been achieved.
  bool get isCSATBonusAchieved {
    return csatSummary != null && 
           csatSummary!.monthlyCSATPercentage >= AppConstants.csatBonusPercentage && 
           totalCalls >= AppConstants.csatBonusCallTarget;
  }

  /// The Tax Deducted at Source (TDS) amount.
  double get tdsDeduction {
    return (totalSalary + csatBonus) * AppConstants.tdsRate;
  }

  /// The final net salary after all bonuses and deductions.
  double get netSalary {
    return totalSalary + csatBonus - tdsDeduction;
  }

  /// A detailed breakdown of the salary components.
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

  /// The average salary per day.
  double get averageSalary {
    if (entries.isEmpty) return 0.0;
    return totalSalary / entries.length;
  }
  
  /// The name of the month (e.g., "January").
  String get monthName {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
  
  /// A formatted string for the month and year (e.g., "June 2025").
  String get formattedMonthYear {
    return '$monthName $year';
  }
  
  @override
  List<Object?> get props => [month, year, entries, csatSummary, cqSummary, nonBillableCalls];
}
