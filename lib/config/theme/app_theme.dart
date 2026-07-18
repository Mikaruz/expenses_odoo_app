import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oh_expenses_app/config/config.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: mainColor),
    textTheme: GoogleFonts.onestTextTheme(),
  );
}
