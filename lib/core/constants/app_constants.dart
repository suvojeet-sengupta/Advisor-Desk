import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // App information
  static const String appName = 'Advisor Desk';
  static const String appVersion = '1.0.8';
  static const String appDeveloper = 'Suvojeet';
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_1');

  // Salary calculation constants
  static double baseRatePerCall = 4.30;
  static double bonusAmount = 2000.0;
  static int bonusCallTarget = 750;
  static int bonusHourTarget = 100; // in hours

  // CSAT Bonus and TDS constants
  static double csatBonusPercentage = 60.0;
  static int csatBonusCallTarget = 1000;
  static double csatBonusRate = 0.05; // 5% of total salary
  static double tdsRate = 0.10; // 10% TDS

  // Database constants
  // Database constants
  static const String databaseName = 'advisor_desk.db';
  static const int databaseVersion = 10; // Updated version for CQ fields
  
  // Table names
  static const String tableEntries = 'daily_entries';
  static const String tableCSATEntries = 'csat_entries';
  static const String tableCQEntries = 'cq_entries'; // New CQ table
  static const String tableLeaveEntries = 'leave_entries'; // New Leave table
  static const String tableMonthlyData = 'monthly_data'; // New Monthly Data table
  static const String tableChatHistory = 'chat_history'; // New Chat History table

  // UI constants
  static const double cardBorderRadius = 12.0;

  // Shared preferences keys
  static const String prefThemeMode = 'theme_mode';

  // SharedPreferences instance
  static late SharedPreferences _prefs;

  // Keys for salary parameters
  static const String _keyBaseRatePerCall = 'baseRatePerCall';
  static const String _keyBonusAmount = 'bonusAmount';
  static const String _keyBonusCallTarget = 'bonusCallTarget';
  static const String _keyBonusHourTarget = 'bonusHourTarget';
  static const String _keyCsatBonusPercentage = 'csatBonusPercentage';
  static const String _keyCsatBonusCallTarget = 'csatBonusCallTarget';
  static const String _keyCsatBonusRate = 'csatBonusRate';
  static const String _keyTdsRate = 'tdsRate';

  // Initialize and load settings
  static Future<void> init({String userId = '1'}) async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings(userId: userId);
  }

  // Load settings from SharedPreferences
  static void _loadSettings({String userId = '1'}) {
    final prefix = userId == '1' ? '' : '${userId}_';

    baseRatePerCall = _prefs.getDouble('$prefix$_keyBaseRatePerCall') ?? 4.30;
    bonusAmount = _prefs.getDouble('$prefix$_keyBonusAmount') ?? 2000.0;
    bonusCallTarget = _prefs.getInt('$prefix$_keyBonusCallTarget') ?? 750;
    bonusHourTarget = _prefs.getInt('$prefix$_keyBonusHourTarget') ?? 100;
    csatBonusPercentage = _prefs.getDouble('$prefix$_keyCsatBonusPercentage') ?? 60.0;
    csatBonusCallTarget = _prefs.getInt('$prefix$_keyCsatBonusCallTarget') ?? 1000;
    csatBonusRate = _prefs.getDouble('$prefix$_keyCsatBonusRate') ?? 0.05;
    tdsRate = _prefs.getDouble('$prefix$_keyTdsRate') ?? 0.10;
  }

  // Save settings to SharedPreferences
  static Future<void> saveSettings({
    required double newBaseRatePerCall,
    required double newBonusAmount,
    required int newBonusCallTarget,
    required int newBonusHourTarget,
    required double newCsatBonusPercentage,
    required int newCsatBonusCallTarget,
    required double newCsatBonusRate,
    required double newTdsRate,
    String userId = '1',
  }) async {
    baseRatePerCall = newBaseRatePerCall;
    bonusAmount = newBonusAmount;
    bonusCallTarget = newBonusCallTarget;
    bonusHourTarget = newBonusHourTarget;
    csatBonusPercentage = newCsatBonusPercentage;
    csatBonusCallTarget = newCsatBonusCallTarget;
    csatBonusRate = newCsatBonusRate;
    tdsRate = newTdsRate;

    final prefix = userId == '1' ? '' : '${userId}_';

    await _prefs.setDouble('$prefix$_keyBaseRatePerCall', baseRatePerCall);
    await _prefs.setDouble('$prefix$_keyBonusAmount', bonusAmount);
    await _prefs.setInt('$prefix$_keyBonusCallTarget', bonusCallTarget);
    await _prefs.setInt('$prefix$_keyBonusHourTarget', bonusHourTarget);
    await _prefs.setDouble('$prefix$_keyCsatBonusPercentage', csatBonusPercentage);
    await _prefs.setInt('$prefix$_keyCsatBonusCallTarget', csatBonusCallTarget);
    await _prefs.setDouble('$prefix$_keyCsatBonusRate', csatBonusRate);
    await _prefs.setDouble('$prefix$_keyTdsRate', tdsRate);
  }
}
