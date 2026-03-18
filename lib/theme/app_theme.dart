import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color buttonDark = Color(0xFF1C1C1E);
  static const Color buttonGray = Color(0xFFD4D4D2);
  static const Color buttonOrange = Color(0xFFFF9500);
  static const Color buttonOrangeActive = Color(0xFFFFAD33);
  static const Color displayText = Colors.white;
  static const Color historyText = Color(0xFF8E8E93);
  static const Color divider = Color(0xFF38383A);

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w300,
    color: displayText,
    letterSpacing: -2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w300,
    color: displayText,
    letterSpacing: -1.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w300,
    color: displayText,
    letterSpacing: -1,
  );

  static const TextStyle historyStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: historyText,
  );

  static const TextStyle buttonLabelLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static const TextStyle buttonLabelGray = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        fontFamily: 'SF Pro Display',
      );
}
