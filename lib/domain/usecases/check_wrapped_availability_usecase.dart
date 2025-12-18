import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

class CheckWrappedAvailabilityUseCase {
  final PerformanceRepository repository;

  CheckWrappedAvailabilityUseCase(this.repository);

  Future<MonthlySummary?> execute() async {
    final now = DateTime.now();
    // Logic: Check for the *previous* month
    // If today is Jan 2026, we check for Dec 2025 Wrapped.
    
    final previousMonthDate = DateTime(now.year, now.month - 1);
    final prevMonth = previousMonthDate.month;
    final prevYear = previousMonthDate.year;

    // 1. Check if we have already shown wrapped for this specific month/year
    final prefs = await SharedPreferences.getInstance();
    final key = 'wrapped_seen_${prevMonth}_$prevYear';
    final hasSeen = prefs.getBool(key) ?? false;

    if (hasSeen) {
      return null;
    }

    // 2. Fetch summary for that month to see if there is data
    try {
      final summary = await repository.getMonthlySummary(prevMonth, prevYear);
      
      // 3. Only show if there were calls (active month)
      if (summary.totalCalls > 0) {
        return summary;
      }
    } catch (e) {
      // If fetching fails or no data, just return null
      return null;
    }

    return null;
  }

  Future<void> markAsSeen(int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'wrapped_seen_${month}_$year';
    await prefs.setBool(key, true);
  }
}
