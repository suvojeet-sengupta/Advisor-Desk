import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/presentation/common/theme/theme_cubit.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
      ),
      body: ListView(
        children: [
          RadioListTile<AppThemeMode>(
            title: const Text('System Default'),
            value: AppThemeMode.system,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.background)),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Light Mode'),
            value: AppThemeMode.light,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark Mode'),
            value: AppThemeMode.dark,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black)),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Orange Mode'),
            value: AppThemeMode.orange,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange)), // Visual indicator
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Teal Mode'),
            value: AppThemeMode.teal,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.teal[700])), // Visual indicator
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Pink Mode'),
            value: AppThemeMode.pink,
            groupValue: context.watch<ThemeCubit>().state,
            onChanged: (AppThemeMode? newValue) {
              if (newValue != null) {
                context.read<ThemeCubit>().setTheme(newValue);
              }
            },
            secondary: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pink[700])), // Visual indicator
          ),
        ],
      ),
    );
  }
}
