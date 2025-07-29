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
          ),
        ],
      ),
    );
  }
}
