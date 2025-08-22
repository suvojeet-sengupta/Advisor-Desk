
import 'package:shared_preferences/shared_preferences.dart';

class TutorialHelper {
  static const String _csatTutorialKey = 'has_seen_csat_tutorial';
  static const String _cqTutorialKey = 'has_seen_cq_tutorial';

  static Future<bool> hasSeenCsatTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_csatTutorialKey) ?? false;
  }

  static Future<void> setCsatTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_csatTutorialKey, true);
  }

  static Future<bool> hasSeenCqTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cqTutorialKey) ?? false;
  }

  static Future<void> setCqTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cqTutorialKey, true);
  }
}
