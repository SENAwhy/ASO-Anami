import 'package:flutter/material.dart';

class AnamiTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C5CE7),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C5CE7),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
