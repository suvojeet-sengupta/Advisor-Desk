import 'package:shared_preferences/shared_preferences.dart';

/// A service for tracking app usage metrics, such as launch count.
///
/// This class provides methods to increment and reset the app launch count,
/// as well as manage the date of the last review request. This data can be
/// used to determine when to prompt the user for a review.
class UsageTrackingService {
  static const _launchCountKey = 'app_launch_count';
  static const _lastReviewRequestDateKey = 'last_review_request_date';

  /// Increments the app launch count stored in [SharedPreferences].
  ///
  /// Returns the updated launch count.
  Future<int> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt(_launchCountKey) ?? 0;
    launchCount++;
    await prefs.setInt(_launchCountKey, launchCount);
    return launchCount;
  }

  /// Resets the app launch count to zero.
  Future<void> resetLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_launchCountKey, 0);
  }

  /// Retrieves the date of the last review request.
  ///
  /// Returns a [DateTime] object if a date is stored, otherwise returns `null`.
  Future<DateTime?> getLastReviewRequestDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastReviewRequestDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Sets the date of the last review request to the given [date].
  Future<void> setLastReviewRequestDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReviewRequestDateKey, date.toIso8601String());
  }
}
