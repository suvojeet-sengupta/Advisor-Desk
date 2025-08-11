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
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            children: [
              _buildAnimatedThemeToggle(context, themeState),
              const Divider(),
              RadioListTile<AppThemeMode>(
                title: const Text('System Default'),
                value: AppThemeMode.system,
                groupValue: themeState.themeMode,
                onChanged: (AppThemeMode? newValue) {
                  if (newValue != null) {
                    context.read<ThemeCubit>().setThemeMode(newValue);
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
              ),
              for (final color in AppColor.values)
                RadioListTile<AppColor>(
                  title: Text(color.toString().split('.').last.toUpperCase()),
                  value: color,
                  groupValue: themeState.color,
                  onChanged: (AppColor? newValue) {
                    if (newValue != null) {
                      context.read<ThemeCubit>().setColor(newValue);
                    }
                  },
                  secondary: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColorForEnum(color),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedThemeToggle(BuildContext context, ThemeState state) {
    final isDarkMode = state.themeMode == AppThemeMode.dark ||
        (state.themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return SwitchListTile(
      title: const Text('Theme'),
      subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
      value: isDarkMode,
      onChanged: (value) {
        final newTheme = value ? AppThemeMode.dark : AppThemeMode.light;
        context.read<ThemeCubit>().setThemeMode(newTheme);
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
  }

  Color _getColorForEnum(AppColor color) {
    switch (color) {
      case AppColor.orange:
        return Colors.orange;
      case AppColor.teal:
        return Colors.teal;
      case AppColor.pink:
        return Colors.pink;
      case AppColor.blue:
        return Colors.blue;
      case AppColor.green:
        return Colors.green;
      case AppColor.purple:
        return Colors.purple;
      case AppColor.red:
        return Colors.red;
    }
  }
}
