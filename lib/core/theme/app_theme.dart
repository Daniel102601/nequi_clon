import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF8A05BE); // Morado más neón
  static const Color darkPurple = Color(0xFF5F01A6);
  static const Color background = Colors.white;

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}