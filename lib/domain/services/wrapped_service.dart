import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/wrapped_stats.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'dart:math';

class WrappedService {
  WrappedStats generateStats(MonthlySummary summary) {
    // 1. Basic Stats
    final totalCalls = summary.totalCalls;
    final totalHours = summary.totalLoginHours;
    final totalEarnings = summary.netSalary;
    final averageCsat = summary.csatSummary?.monthlyCSATPercentage ?? 0.0;
    final averageCq = summary.cqSummary?.monthlyAverageCQ ?? 0.0;
    final monthName = summary.monthName;
    final year = summary.year;

    // 2. Best Day Logic
    DailyEntry? bestDay;
    int maxCalls = -1;

    for (final entry in summary.entries) {
      if (entry.callCount > maxCalls) {
        maxCalls = entry.callCount;
        bestDay = entry;
      }
    }

    // 3. Persona Logic
    String persona = "The Rising Star";
    String description = "You're building momentum and making your mark!";

    // Thresholds (Customize these based on realistic app data)
    final bool highCalls = totalCalls > 2500;
    final bool highHours = totalHours > 220; // Approx 9 hours/day for 24 days
    final bool highCsat = averageCsat >= 90;
    final bool goodCsat = averageCsat >= 80;
    final bool targetsMet = summary.isBonusAchieved;

    if (highCsat && highCalls) {
       persona = "The Legend";
       description = "Top-tier quality AND quantity. You are simply unstoppable.";
    } else if (highCsat) {
      persona = "The Customer Whisperer";
      description = "Your customers absolutely love you. Quality is your middle name.";
    } else if (highCalls) {
      persona = "The Machine";
      description = "You were on fire! Crushing call volumes like it's nothing.";
    } else if (highHours) {
      persona = "The Marathon Runner";
      description = "Your dedication and consistency are unmatched.";
    } else if (targetsMet && goodCsat) {
      persona = "The All-Rounder";
      description = "You balanced everything perfectly. Consistency is key!";
    }

    return WrappedStats(
      totalCalls: totalCalls,
      totalHours: totalHours,
      bestDayDate: bestDay?.date,
      bestDayCalls: maxCalls > -1 ? maxCalls : 0,
      averageCsat: averageCsat,
      averageCq: averageCq,
      totalEarnings: totalEarnings,
      advisorPersona: persona,
      personaDescription: description,
      monthName: monthName,
      year: year,
    );
  }
}
