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
    AppColor.orange: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFFF7043), // Deep Orange 400
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD84315), // Darker orange for container
      onPrimaryContainer: const Color(0xFFFBE9E7), // Lighter text on container
      secondary: const Color(0xFFFF7043),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD84315),
      onSecondaryContainer: const Color(0xFFFBE9E7),
      tertiary: const Color(0xFFFF7043),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD84315),
      onTertiaryContainer: const Color(0xFFFBE9E7),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFFFF7043), // Original vibrant orange for inverse
      surfaceTint: const Color(0xFFFF7043),
    ),
    AppColor.teal: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF26A69A), // Teal 400
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF00796B), // Darker teal for container
      onPrimaryContainer: const Color(0xFFE0F2F1), // Lighter text on container
      secondary: const Color(0xFF26A69A),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF00796B),
      onSecondaryContainer: const Color(0xFFE0F2F1),
      tertiary: const Color(0xFF26A69A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF00796B),
      onTertiaryContainer: const Color(0xFFE0F2F1),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFF26A69A), // Original vibrant teal for inverse
      surfaceTint: const Color(0xFF26A69A),
    ),
    AppColor.pink: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFEC407A), // Pink 400
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFC2185B), // Darker pink for container
      onPrimaryContainer: const Color(0xFFFCE4EC), // Lighter text on container
      secondary: const Color(0xFFEC407A),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFC2185B),
      onSecondaryContainer: const Color(0xFFFCE4EC),
      tertiary: const Color(0xFFEC407A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFC2185B),
      onTertiaryContainer: const Color(0xFFFCE4EC),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFFEC407A), // Original vibrant pink for inverse
      surfaceTint: const Color(0xFFEC407A),
    ),
    AppColor.blue: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF42A5F5), // Blue 400
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1976D2), // Darker blue for container
      onPrimaryContainer: const Color(0xFFE3F2FD), // Lighter text on container
      secondary: const Color(0xFF42A5F5),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF1976D2),
      onSecondaryContainer: const Color(0xFFE3F2FD),
      tertiary: const Color(0xFF42A5F5),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF1976D2),
      onTertiaryContainer: const Color(0xFFE3F2FD),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFF42A5F5), // Original vibrant blue for inverse
      surfaceTint: const Color(0xFF42A5F5),
    ),
    AppColor.purple: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFAB47BC), // Purple 400
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF7B1FA2), // Darker purple for container
      onPrimaryContainer: const Color(0xFFF3E5F5), // Lighter text on container
      secondary: const Color(0xFFAB47BC),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF7B1FA2),
      onSecondaryContainer: const Color(0xFFF3E5F5),
      tertiary: const Color(0xFFAB47BC),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF7B1FA2),
      onTertiaryContainer: const Color(0xFFF3E5F5),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFFAB47BC), // Original vibrant purple for inverse
      surfaceTint: const Color(0xFFAB47BC),
    ),
    AppColor.red: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFE57373), // Red 300
      onPrimary: Colors.black,
      primaryContainer: const Color(0xFFD32F2F), // Darker red for container
      onPrimaryContainer: const Color(0xFFFFCDD2), // Lighter text on container
      secondary: const Color(0xFFE57373), // Using same for secondary for consistency
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFFD32F2F),
      onSecondaryContainer: const Color(0xFFFFCDD2),
      tertiary: const Color(0xFFE57373),
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFFD32F2F),
      onTertiaryContainer: const Color(0xFFFFCDD2),
      error: const Color(0xFFCF6679), // Standard error color
      onError: Colors.black,
      errorContainer: const Color(0xFFB00020),
      onErrorContainer: Colors.white,
      background: Colors.black, // True black background for AMOLED
      onBackground: Colors.white,
      surface: const Color(0xFF121212), // Dark gray for surface
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF121212), // Dark gray for surface variant
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFFB3B3B3), // Light outline
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFFE57373), // Original vibrant red for inverse
      surfaceTint: const Color(0xFFE57373),
    ),
  };

  static ThemeData getTheme(AppThemeMode themeMode, AppColor color) {
    final brightness = themeMode == AppThemeMode.light
        ? Brightness.light
        : themeMode == AppThemeMode.dark
            ? Brightness.dark
            : WidgetsBinding.instance.platformDispatcher.platformBrightness;

    ColorScheme colorScheme;
    if (brightness == Brightness.light) {
      colorScheme = _lightColorSchemes[color] ?? _lightColorSchemes[AppColor.blue]!;
    } else {
      colorScheme = _darkColorSchemes[color] ?? _darkColorSchemes[AppColor.blue]!;
    }
    
    return brightness == Brightness.light 
        ? getLightTheme(colorScheme) 
        : getDarkTheme(colorScheme);
  }

  static ThemeData getLightTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow ?? colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest ?? colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, letterSpacing: -1),
        headlineMedium: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(color: colorSurface(colorScheme), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: colorScheme.onSurface, fontSize: 16),
        bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  static Color colorSurface(ColorScheme scheme) => scheme.onSurface;

  static ThemeData getDarkTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer ?? colorScheme.surfaceVariant.withOpacity(0.2),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh ?? colorScheme.surfaceVariant.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, letterSpacing: -1),
        headlineMedium: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: colorScheme.onSurface, fontSize: 16),
        bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }
}