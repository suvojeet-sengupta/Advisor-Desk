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
          _buildAnimatedThemeToggle(context),
          const Divider(),
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

  Widget _buildAnimatedThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, state) {
        final isDarkMode = state == AppThemeMode.dark ||
            (state == AppThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return SwitchListTile(
          title: const Text('Theme'),
          subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
          value: isDarkMode,
          onChanged: (value) {
            final newTheme = value ? AppThemeMode.dark : AppThemeMode.light;
            context.read<ThemeCubit>().setTheme(newTheme);
          },
          secondary: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: isDarkMode
                ? Icon(Icons.nightlight_round, key: UniqueKey())
                : Icon(Icons.wb_sunny, key: UniqueKey()),
          ),
        );
      },
    );
  }
}
