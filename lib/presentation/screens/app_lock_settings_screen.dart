import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A screen for configuring the app lock timeout settings.
///
/// This screen allows the user to choose how long the app can be in the
/// background before it requires authentication upon being reopened.
/// The selected setting is persisted using [SharedPreferences].
class AppLockSettingsScreen extends StatefulWidget {
  /// Creates an [AppLockSettingsScreen].
  const AppLockSettingsScreen({super.key});

  @override
  State<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends State<AppLockSettingsScreen> {
  String _selectedOption = 'Immediately';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the saved timeout setting from SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption =
          prefs.getString('authentication_timeout') ?? 'Immediately';
    });
  }

  /// Saves the selected timeout setting to SharedPreferences.
  Future<void> _saveSetting(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authentication_timeout', value);
    setState(() {
      _selectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock Settings'),
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('Immediately'),
            value: 'Immediately',
            groupValue: _selectedOption,
            onChanged: (value) => _saveSetting(value!),
          ),
          RadioListTile<String>(
            title: const Text('1 Minute'),
            value: '1_minute',
            groupValue: _selectedOption,
            onChanged: (value) => _saveSetting(value!),
          ),
          RadioListTile<String>(
            title: const Text('3 Minutes'),
            value: '3_minutes',
            groupValue: _selectedOption,
            onChanged: (value) => _saveSetting(value!),
          ),
          RadioListTile<String>(
            title: const Text('5 Minutes'),
            value: '5_minutes',
            groupValue: _selectedOption,
            onChanged: (value) => _saveSetting(value!),
          ),
        ],
      ),
    );
  }
}
