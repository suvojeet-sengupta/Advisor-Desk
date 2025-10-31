import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class ThemeState {
  final AppThemeMode themeMode;
  final AppColor color;

  const ThemeState({required this.themeMode, required this.color});

  ThemeState copyWith({
    AppThemeMode? themeMode,
    AppColor? color,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      color: color ?? this.color,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeModePrefKey = 'theme_mode';
  static const String _themeColorPrefKey = 'theme_color';

  ThemeCubit({required AppThemeMode initialThemeMode, required AppColor initialColor})
      : super(ThemeState(themeMode: initialThemeMode, color: initialColor));

  void setThemeMode(AppThemeMode newThemeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModePrefKey, newThemeMode.index);
    emit(state.copyWith(themeMode: newThemeMode));
  }

  void setColor(AppColor newColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorPrefKey, newColor.index);
    emit(state.copyWith(color: newColor));
  }
}
