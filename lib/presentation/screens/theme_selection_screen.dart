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
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('Light'),
                value: AppThemeMode.light,
                groupValue: themeState.themeMode,
                onChanged: (AppThemeMode? newValue) {
                  if (newValue != null) {
                    context.read<ThemeCubit>().setThemeMode(newValue);
                  }
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('Dark'),
                value: AppThemeMode.dark,
                groupValue: themeState.themeMode,
                onChanged: (AppThemeMode? newValue) {
                  if (newValue != null) {
                    context.read<ThemeCubit>().setThemeMode(newValue);
                  }
                },
              ),
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
                  title: Text(
                    color == AppColor.materialYou
                        ? 'Material You'
                        : color.toString().split('.').last.toUpperCase(),
                  ),
                  subtitle: color == AppColor.materialYou
                      ? const Text('Uses wallpaper colors (Android 12+)')
                      : null,
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

  

  Color _getColorForEnum(AppColor color) {
    switch (color) {
      case AppColor.materialYou:
        return Colors.blueGrey; // Placeholder color for the radio button circle
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
