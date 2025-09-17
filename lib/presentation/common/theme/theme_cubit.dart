import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

/// Represents the state of the application's theme.
///
/// This class holds the current [themeMode] and accent [color].
class ThemeState {
  /// The current theme mode (system, light, or dark).
  final AppThemeMode themeMode;
  /// The current accent color.
  final AppColor color;

  /// Creates a new instance of [ThemeState].
  const ThemeState({required this.themeMode, required this.color});

  /// Creates a copy of this [ThemeState] but with the given fields replaced with new values.
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

/// A [Cubit] that manages the application's theme state.
///
/// This class handles loading the theme from [SharedPreferences] and allows
/// the user to change the theme mode and accent color.
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeModePrefKey = 'theme_mode';
  static const String _themeColorPrefKey = 'theme_color';

  /// Creates a new instance of [ThemeCubit].
  ///
  /// It initializes with a default theme and then loads the saved theme.
  ThemeCubit() : super(const ThemeState(themeMode: AppThemeMode.system, color: AppColor.orange)) {
    _loadTheme();
  }

  /// Loads the saved theme mode and color from [SharedPreferences].
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModePrefKey) ?? AppThemeMode.system.index;
    final colorIndex = prefs.getInt(_themeColorPrefKey) ?? AppColor.orange.index;
    emit(ThemeState(
      themeMode: AppThemeMode.values[themeModeIndex],
      color: AppColor.values[colorIndex],
    ));
  }

  /// Sets the theme mode and saves it to [SharedPreferences].
  ///
  /// The [newThemeMode] is the new theme mode to be applied.
  void setThemeMode(AppThemeMode newThemeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModePrefKey, newThemeMode.index);
    emit(state.copyWith(themeMode: newThemeMode));
  }

  /// Sets the accent color and saves it to [SharedPreferences].
  ///
  /// The [newColor] is the new accent color to be applied.
  void setColor(AppColor newColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorPrefKey, newColor.index);
    emit(state.copyWith(color: newColor));
  }
}
