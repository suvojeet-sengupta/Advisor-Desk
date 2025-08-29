
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewHelper {
  InAppReviewHelper._();

  static const String _lastPromptDateKey = 'last_review_prompt_date';
  static const String _installDateKey = 'install_date';
  static const String _actionCountKey = 'review_action_count';

  static final InAppReview _inAppReview = InAppReview.instance;

  // Call this method from main.dart on first launch
  static Future<void> setInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    final installDate = prefs.getString(_installDateKey);
    if (installDate == null) {
      await prefs.setString(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  // Call this method after a significant positive event
  static Future<void> incrementActionCountAndRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    // Increment action count
    int actionCount = prefs.getInt(_actionCountKey) ?? 0;
    actionCount++;
    await prefs.setInt(_actionCountKey, actionCount);

    // Check if conditions are met to show the review prompt
    if (await _shouldShowReviewPrompt(actionCount)) {
      _showReviewPrompt(prefs);
    }
  }

  static Future<bool> _shouldShowReviewPrompt(int actionCount) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check if enough days have passed since installation (e.g., 10 days)
    final installDateString = prefs.getString(_installDateKey);
    if (installDateString == null) {
      // If install date isn't set, don't show prompt
      return false;
    }
    final installDate = DateTime.parse(installDateString);
    if (DateTime.now().difference(installDate).inDays < 10) {
      return false;
    }

    // 2. Check if enough time has passed since the last prompt (e.g., 30 days)
    final lastPromptDateString = prefs.getString(_lastPromptDateKey);
    if (lastPromptDateString != null) {
      final lastPromptDate = DateTime.parse(lastPromptDateString);
      if (DateTime.now().difference(lastPromptDate).inDays < 30) {
        return false;
      }
    }

    // 3. Check if enough significant actions have been performed (e.g., 3 actions)
    if (actionCount < 3) {
      return false;
    }

    return true;
  }

  static Future<void> _showReviewPrompt(SharedPreferences prefs) async {
    final isAvailable = await _inAppReview.isAvailable();
    if (isAvailable) {
      _inAppReview.requestReview();
      // Reset counters and update prompt date
      await prefs.setString(_lastPromptDateKey, DateTime.now().toIso8601String());
      await prefs.setInt(_actionCountKey, 0); // Reset action count after showing
    }
  }
}
