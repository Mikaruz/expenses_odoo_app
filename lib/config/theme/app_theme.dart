import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oh_expenses_app/config/config.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: paperColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mainColor,
      brightness: Brightness.light,
      primary: mainColor,
      surface: surfaceColor,
      error: dangerColor,
    ),
    textTheme: GoogleFonts.onestTextTheme().apply(
      bodyColor: inkColor,
      displayColor: inkColor,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: paperColor,
      foregroundColor: inkColor,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: inkColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: receiptColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: mainColor, width: 1.4),
      ),
    ),
  );
}
