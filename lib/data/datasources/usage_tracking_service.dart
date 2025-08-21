import 'package:shared_preferences/shared_preferences.dart';

class UsageTrackingService {
  static const _launchCountKey = 'app_launch_count';
  static const _lastReviewRequestDateKey = 'last_review_request_date';

  Future<int> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt(_launchCountKey) ?? 0;
    launchCount++;
    await prefs.setInt(_launchCountKey, launchCount);
    return launchCount;
  }

  Future<void> resetLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_launchCountKey, 0);
  }

  Future<DateTime?> getLastReviewRequestDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastReviewRequestDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> setLastReviewRequestDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReviewRequestDateKey, date.toIso8601String());
  }
}
