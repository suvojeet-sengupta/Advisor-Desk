import 'package:flutter/material.dart';

/// Represents the theme for a shareable performance card.
///
/// This class defines the visual properties of a share card, including its
/// background gradient and text colors.
class ShareCardTheme {
  /// The background gradient colors.
  final List<Color> backgroundGradient;
  /// The color of the main text.
  final Color textColor;
  /// The color of icons on the card.
  final Color iconColor;
  /// The color of the footer text.
  final Color footerTextColor;

  /// Creates a new instance of [ShareCardTheme].
  const ShareCardTheme({
    required this.backgroundGradient,
    required this.textColor,
    required this.iconColor,
    required this.footerTextColor,
  });
}

/// A list of predefined themes for the shareable performance card.
final List<ShareCardTheme> shareCardThemes = [
  const ShareCardTheme(
    backgroundGradient: [Color(0xFF004D40), Color(0xFF00796B)],
    textColor: Colors.white,
    iconColor: Colors.white,
    footerTextColor: Colors.white70,
  ),
  const ShareCardTheme(
    backgroundGradient: [Color(0xFF880E4F), Color(0xFFC2185B)],
    textColor: Colors.white,
    iconColor: Colors.white,
    footerTextColor: Colors.white70,
  ),
  const ShareCardTheme(
    backgroundGradient: [Color(0xFF1A237E), Color(0xFF303F9F)],
    textColor: Colors.white,
    iconColor: Colors.white,
    footerTextColor: Colors.white70,
  ),
  const ShareCardTheme(
    backgroundGradient: [Color(0xFFBF360C), Color(0xFFE64A19)],
    textColor: Colors.white,
    iconColor: Colors.white,
    footerTextColor: Colors.white70,
  ),
  const ShareCardTheme(
    backgroundGradient: [Color(0xFF263238), Color(0xFF455A64)],
    textColor: Colors.white,
    iconColor: Colors.white,
    footerTextColor: Colors.white70,
  ),
];
