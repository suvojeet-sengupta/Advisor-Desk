import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';

/// Represents a comprehensive summary of performance for a specific date range.
///
/// This class is similar to [MonthlySummary] but is designed for custom date
/// ranges. It aggregates performance data and calculates various metrics,
/// including salary details, for the given period.
class ReportSummary extends Equatable {
  /// The start date of the report period.
  final DateTime startDate;
  /// The end date of the report period.
  final DateTime endDate;
  /// The list of daily performance entries for the period.
  final List<DailyEntry> entries;
  /// The CSAT summary for the period.
  final CSATSummary? csatSummary;
  /// The CQ summary for the period.
  final CQSummary? cqSummary;

  /// Creates a new instance of [ReportSummary].
  const ReportSummary({
    required this.startDate,
    required this.endDate,
    required this.entries,
    this.csatSummary,
    this.cqSummary,
  });

  /// The total login hours for the period.
  double get totalLoginHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.totalLoginTimeInHours);
  }

  /// The total number of calls made in the period.
  int get totalCalls {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.callCount);
  }

  /// The total number of billable calls for the period.
  int get billableCalls {
    return totalCalls;
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
      'Base Salary': baseSalary,
      'Bonus Amount': bonusAmount,
      'CSAT Bonus': csatBonus,
      'Gross Salary': totalSalary + csatBonus,
      'TDS Deduction': tdsDeduction,
      'Net Salary': netSalary,
    };
  }

  /// A formatted string representing the date range of the report.
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
