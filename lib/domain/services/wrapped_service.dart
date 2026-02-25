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
    String persona = "The Dedicated Professional";
    String description = "You show up every day and get the job done. Reliability is your superpower!";

    // Thresholds (Refined)
    final bool highCalls = totalCalls > 3000;
    final bool moderateCalls = totalCalls > 2000;
    final bool highHours = totalHours > 220; 
    final bool moderateHours = totalHours > 180;
    final bool eliteQuality = averageCsat >= 95 && averageCq >= 95;
    final bool highQuality = averageCsat >= 90 && averageCq >= 90;
    final bool goodQuality = averageCsat >= 85 && averageCq >= 85;

    if (highCalls && eliteQuality) {
       persona = "The G.O.A.T.";
       description = "Greatest Of All Time. Unmatched speed, volume, and perfection. You're in a league of your own!";
    } else if (highCalls && highQuality) {
       persona = "The Powerhouse";
       description = "A perfect blend of high energy and sharp focus. You're the engine of the floor!";
    } else if (eliteQuality) {
      persona = "The Perfectionist";
      description = "Every call you handle is a masterpiece. Your quality scores are legendary.";
    } else if (highCalls) {
      persona = "The Sonic";
      description = "Fast, efficient, and unstoppable. You handle calls like a blur!";
    } else if (highHours && goodQuality) {
      persona = "The Iron Pillar";
      description = "Your stamina and consistent quality are the foundation of excellence.";
    } else if (moderateCalls && highQuality) {
      persona = "The Precision Expert";
      description = "Every move is calculated, every word is perfect. You're the go-to for quality.";
    } else if (totalCalls < 500 && highQuality) {
       persona = "The Quality Specialist";
       description = "You may handle fewer calls, but each one is handled with extreme care and excellence.";
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
