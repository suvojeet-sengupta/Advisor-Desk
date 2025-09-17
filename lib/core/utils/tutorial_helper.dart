import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for managing tutorial flags.
///
/// This class provides methods to check if the user has seen specific tutorials
/// (e.g., for CSAT and CQ) and to mark them as seen. This is useful for
/// showing tutorials only once to the user.
class TutorialHelper {
  static const String _csatTutorialKey = 'has_seen_csat_tutorial';
  static const String _cqTutorialKey = 'has_seen_cq_tutorial';

  /// Checks if the user has seen the CSAT (Customer Satisfaction) tutorial.
  ///
  /// Returns `true` if the tutorial has been seen, `false` otherwise.
  static Future<bool> hasSeenCsatTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_csatTutorialKey) ?? false;
  }

  /// Marks the CSAT (Customer Satisfaction) tutorial as seen.
  static Future<void> setCsatTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_csatTutorialKey, true);
  }

  /// Checks if the user has seen the CQ (Call Quality) tutorial.
  ///
  /// Returns `true` if the tutorial has been seen, `false` otherwise.
  static Future<bool> hasSeenCqTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cqTutorialKey) ?? false;
  }

  /// Marks the CQ (Call Quality) tutorial as seen.
  static Future<void> setCqTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cqTutorialKey, true);
  }
}
