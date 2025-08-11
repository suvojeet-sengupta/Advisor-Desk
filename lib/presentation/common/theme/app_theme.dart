import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class AppTheme {
  AppTheme._();

  static final Map<AppColor, ColorScheme> _lightColorSchemes = {
    AppColor.orange: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent, brightness: Brightness.light),
    AppColor.teal: ColorScheme.fromSeed(seedColor: Colors.tealAccent[400]!, brightness: Brightness.light),
    AppColor.pink: ColorScheme.fromSeed(seedColor: Colors.pinkAccent[400]!, brightness: Brightness.light),
    AppColor.blue: ColorScheme.fromSeed(seedColor: Colors.blueAccent[700]!, brightness: Brightness.light),
    AppColor.green: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent[700]!, brightness: Brightness.light),
    AppColor.purple: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent[400]!, brightness: Brightness.light),
    AppColor.red: ColorScheme.fromSeed(seedColor: Colors.redAccent[700]!, brightness: Brightness.light),
  };

  static final Map<AppColor, ColorScheme> _darkColorSchemes = {
    AppColor.orange: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent, brightness: Brightness.dark),
    AppColor.teal: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF80CBC4), // Teal 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF004D40), // Darker teal for container
      onPrimaryContainer: Color(0xFFE0F2F1), // Lighter text on container
      secondary: Color(0xFF80CBC4), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF004D40),
      onSecondaryContainer: Color(0xFFE0F2F1),
      tertiary: Color(0xFF80CBC4),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF004D40),
      onTertiaryContainer: Color(0xFFE0F2F1),
      error: Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Color(0xFF121212), // Dark background
      onBackground: Colors.white,
      surface: Color(0xFF121212), // Dark surface
      onSurface: Colors.white,
      surfaceVariant: Color(0xFF424242), // Slightly lighter surface variant
      onSurfaceVariant: Colors.white,
      outline: Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: Color(0xFF00897B), // Original vibrant teal for inverse
      surfaceTint: Color(0xFF80CBC4),
    ),
    AppColor.pink: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF48FB1), // Pink 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF880E4F), // Darker pink for container
      onPrimaryContainer: Color(0xFFFCE4EC), // Lighter text on container
      secondary: Color(0xFFF48FB1), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF880E4F),
      onSecondaryContainer: Color(0xFFFCE4EC),
      tertiary: Color(0xFFF48FB1),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF880E4F),
      onTertiaryContainer: Color(0xFFFCE4EC),
      error: Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Color(0xFF121212), // Dark background
      onBackground: Colors.white,
      surface: Color(0xFF121212), // Dark surface
      onSurface: Colors.white,
      surfaceVariant: Color(0xFF424242), // Slightly lighter surface variant
      onSurfaceVariant: Colors.white,
      outline: Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: Color(0xFFD81B60), // Original vibrant pink for inverse
      surfaceTint: Color(0xFFF48FB1),
    ),
    AppColor.blue: ColorScheme.fromSeed(seedColor: Colors.blueAccent[700]!, brightness: Brightness.dark),
    AppColor.green: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent[700]!, brightness: Brightness.dark),
    AppColor.purple: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent[400]!, brightness: Brightness.dark),
    AppColor.red: ColorScheme.fromSeed(seedColor: Colors.redAccent[700]!, brightness: Brightness.dark),
  };

  static ThemeData getTheme(Brightness brightness, AppColor color) {
    final colorScheme = brightness == Brightness.light
        ? _lightColorSchemes[color]!
        : _darkColorSchemes[color]!;
    
    return brightness == Brightness.light 
        ? getLightTheme(colorScheme) 
        : getDarkTheme(colorScheme);
  }

  static ThemeData getLightTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F7),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}