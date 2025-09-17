import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for managing in-app reviews.
///
/// This class provides functionality to prompt the user for a review at an
/// appropriate time, based on factors like installation date, time since the
/// last prompt, and user engagement (action count).
class InAppReviewHelper {
  InAppReviewHelper._();

  static const String _lastPromptDateKey = 'last_review_prompt_date';
  static const String _installDateKey = 'install_date';
  static const String _actionCountKey = 'review_action_count';

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Sets the installation date of the app in [SharedPreferences].
  ///
  /// This should be called once when the app is first launched.
  static Future<void> setInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    final installDate = prefs.getString(_installDateKey);
    if (installDate == null) {
      await prefs.setString(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  /// Increments the action counter and, if conditions are met, requests a review.
  ///
  /// This method should be called after a significant positive event in the app,
  /// such as completing a key task. It checks if enough time has passed and
  /// enough actions have been performed before showing the review prompt.
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

  /// Determines whether the in-app review prompt should be shown.
  ///
  /// The [actionCount] is the number of significant actions the user has performed.
  ///
  /// Returns `true` if all conditions (e.g., days since install, days since
  /// last prompt, action count) are met.
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

  /// Shows the in-app review prompt to the user.
  ///
  /// The [prefs] are the shared preferences instance.
  ///
  /// If the review prompt is shown, it updates the last prompt date and resets
  /// the action counter.
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
