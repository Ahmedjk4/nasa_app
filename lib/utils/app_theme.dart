import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0B132B);
  static const Color secondaryColor = Color(0xFF3A506B);

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
