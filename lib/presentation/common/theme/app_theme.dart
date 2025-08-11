import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class AppTheme {
  AppTheme._();

  static final Map<AppColor, ColorScheme> _lightColorSchemes = {
    AppColor.orange: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.deepOrange[400]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.deepOrange[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.deepOrange[400]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.deepOrange[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.deepOrange[400]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.deepOrange[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.deepOrange[100]!,
      surfaceTint: Colors.deepOrange[400]!,
    ),
    AppColor.teal: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.teal[400]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.teal[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.teal[400]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.teal[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.teal[400]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.teal[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.teal[100]!,
      surfaceTint: Colors.teal[400]!,
    ),
    AppColor.pink: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.pink[400]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.pink[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.pink[400]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.pink[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.pink[400]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.pink[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.pink[100]!,
      surfaceTint: Colors.pink[400]!,
    ),
    AppColor.blue: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue[600]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.blue[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.blue[600]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.blue[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.blue[600]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.blue[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.blue[100]!,
      surfaceTint: Colors.blue[600]!,
    ),
    AppColor.green: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.green[600]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.green[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.green[600]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.green[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.green[600]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.green[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.green[100]!,
      surfaceTint: Colors.green[600]!,
    ),
    AppColor.purple: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.purple[600]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.purple[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.purple[600]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.purple[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.purple[600]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.purple[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.purple[100]!,
      surfaceTint: Colors.purple[600]!,
    ),
    AppColor.red: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.red[600]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.red[100]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.red[600]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.red[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.red[600]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.red[100]!,
      onTertiaryContainer: Colors.black,
      error: Colors.red[700]!,
      onError: Colors.white,
      errorContainer: Colors.red[100]!,
      onErrorContainer: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Colors.grey[200]!,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey[400]!,
      shadow: Colors.black,
      inverseSurface: Colors.grey[800]!,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.red[100]!,
      surfaceTint: Colors.red[600]!,
    ),
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
    AppColor.blue: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF90CAF9), // Blue 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF0D47A1), // Darker blue for container
      onPrimaryContainer: Color(0xFFE3F2FD), // Lighter text on container
      secondary: Color(0xFF90CAF9), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF0D47A1),
      onSecondaryContainer: Color(0xFFE3F2FD),
      tertiary: Color(0xFF90CAF9),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF0D47A1),
      onTertiaryContainer: Color(0xFFE3F2FD),
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
      inversePrimary: Color(0xFF2196F3), // Original vibrant blue for inverse
      surfaceTint: Color(0xFF90CAF9),
    ),
    AppColor.green: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFA5D6A7), // Green 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF1B5E20), // Darker green for container
      onPrimaryContainer: Color(0xFFE8F5E9), // Lighter text on container
      secondary: Color(0xFFA5D6A7), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF1B5E20),
      onSecondaryContainer: Color(0xFFE8F5E9),
      tertiary: Color(0xFFA5D6A7),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF1B5E20),
      onTertiaryContainer: Color(0xFFE8F5E9),
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
      inversePrimary: Color(0xFF4CAF50), // Original vibrant green for inverse
      surfaceTint: Color(0xFFA5D6A7),
    ),
    AppColor.purple: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFCE93D8), // Purple 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF4A148C), // Darker purple for container
      onPrimaryContainer: Color(0xFFF3E5F5), // Lighter text on container
      secondary: Color(0xFFCE93D8), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF4A148C),
      onSecondaryContainer: Color(0xFFF3E5F5),
      tertiary: Color(0xFFCE93D8),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF4A148C),
      onTertiaryContainer: Color(0xFFF3E5F5),
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
      inversePrimary: Color(0xFF9C27B0), // Original vibrant purple for inverse
      surfaceTint: Color(0xFFCE93D8),
    ),
    AppColor.red: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFEF9A9A), // Red 200
      onPrimary: Colors.black,
      primaryContainer: Color(0xFFB71C1C), // Darker red for container
      onPrimaryContainer: Color(0xFFFFEBEE), // Lighter text on container
      secondary: Color(0xFFEF9A9A), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFFB71C1C),
      onSecondaryContainer: Color(0xFFFFEBEE),
      tertiary: Color(0xFFEF9A9A),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFFB71C1C),
      onTertiaryContainer: Color(0xFFFFEBEE),
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
      inversePrimary: Color(0xFFF44336), // Original vibrant red for inverse
      surfaceTint: Color(0xFFEF9A9A),
    ),
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