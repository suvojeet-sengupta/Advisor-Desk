import 'package:flutter/material.dart';

/// A class that holds all the color constants used throughout the application.
/// This class provides a centralized way to manage the app's color scheme.
class AppColors {
  // Primary colors
  /// The primary dark color, often used for main backgrounds.
  static const Color primaryDark = Color(0xFF1F1F1F);
  /// The primary background color.
  static const Color primaryBackground = Color(0xFF282828);
  /// The secondary background color, used for surfaces that need to stand out from the primary background.
  static const Color secondaryBackground = Color(0xFF363636);
  /// The background color for cards and other elevated surfaces.
  static const Color cardBackground = Color(0xFF303030);
  
  // Text colors
  /// The primary text color, typically for headings and important text.
  static const Color textPrimary = Colors.white;
  /// The secondary text color, for less important text and subtitles.
  static const Color textSecondary = Color(0xFFB3B3B3);
  /// The color for hint text in input fields.
  static const Color textHint = Color(0xFF8E8E8E);
  
  // Accent colors
  /// An accent color for interactive elements like buttons and links.
  static const Color accentBlue = Color(0xFF2196F3);
  /// An accent color used to indicate success or positive actions.
  static const Color accentGreen = Color(0xFF4CAF50);
  /// An accent color used to indicate errors or destructive actions.
  static const Color accentRed = Color(0xFFF44336);
  /// A purple accent color for special highlights.
  static const Color accentPurple = Color(0xFF9C27B0);
  
  // Chart colors
  /// The color used for lines in charts.
  static const Color chartLine = accentBlue;
  
  // Divider and border colors
  /// The color for dividers and separators.
  static const Color divider = Color(0xFF4A4A4A);
  /// The color for borders around containers and input fields.
  static const Color border = Color(0xFF505050);
}
