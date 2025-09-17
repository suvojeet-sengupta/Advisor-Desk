import 'package:shared_preferences/shared_preferences.dart';

/// A data source for managing user goals using [SharedPreferences].
///
/// This class provides methods to save and retrieve the user's monthly goals
/// for login hours and call count.
class GoalDataSource {
  static const _hoursKey = 'goal_hours';
  static const _callsKey = 'goal_calls';

  /// Saves the user's goals for login hours and call count.
  ///
  /// The [hours] parameter is the target number of login hours.
  /// The [calls] parameter is the target number of calls.
  Future<void> saveGoals({required int hours, required int calls}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hoursKey, hours);
    await prefs.setInt(_callsKey, calls);
  }

  /// Retrieves the user's saved goals.
  ///
  /// If no goals are saved, it returns default values (150 hours, 1000 calls).
  /// Returns a `Map<String, int>` containing the 'hours' and 'calls' goals.
  Future<Map<String, int>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final hours = prefs.getInt(_hoursKey) ?? 150; // Default goal
    final calls = prefs.getInt(_callsKey) ?? 1000; // Default goal
    return {'hours': hours, 'calls': calls};
  }
}
