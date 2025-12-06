import 'package:shared_preferences/shared_preferences.dart';

class GoalDataSource {
  static const _hoursKey = 'goal_hours';
  static const _callsKey = 'goal_calls';

  Future<void> saveGoals({required int hours, required int calls, required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = userId == '1' ? '' : '${userId}_';
    await prefs.setInt('$prefix$_hoursKey', hours);
    await prefs.setInt('$prefix$_callsKey', calls);
  }

  Future<Map<String, dynamic>> getGoals({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = userId == '1' ? '' : '${userId}_';
    final hours = prefs.getInt('$prefix$_hoursKey') ?? 150; // डिफ़ॉल्ट लक्ष्य
    final calls = prefs.getInt('$prefix$_callsKey') ?? 1000; // डिफ़ॉल्ट लक्ष्य
    final isSet = prefs.containsKey('$prefix$_hoursKey') || prefs.containsKey('$prefix$_callsKey');
    return {'hours': hours, 'calls': calls, 'isSet': isSet};
  }
}
