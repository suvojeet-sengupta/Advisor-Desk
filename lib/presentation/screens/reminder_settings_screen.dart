
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/data/datasources/notification_service.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({Key? key}) : super(key: key);

  @override
  _ReminderSettingsScreenState createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _remindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadReminderSetting();
  }

  Future<void> _loadReminderSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? false;
    });
  }

  Future<void> _updateReminderSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', enabled);
    setState(() {
      _remindersEnabled = enabled;
    });

    final notificationService = context.read<NotificationService>();
    if (enabled) {
      await notificationService.scheduleDailyReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders enabled!')),
      );
    } else {
      await notificationService.cancelAllReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders disabled!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reminder Settings'),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Daily Reminders'),
            subtitle: const Text('Receive notifications to add your daily entry.'),
            value: _remindersEnabled,
            onChanged: _updateReminderSetting,
          ),
        ],
      ),
    );
  }
}
