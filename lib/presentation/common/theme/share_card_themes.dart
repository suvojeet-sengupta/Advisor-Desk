
import 'package:flutter/material.dart';

class ShareCardTheme {
  final List<Color> backgroundGradient;
  final Color textColor;
  final Color iconColor;
  final Color footerTextColor;

  const ShareCardTheme({
    required this.backgroundGradient,
    required this.textColor,
    required this.iconColor,
    required this.footerTextColor,
  });
}

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
