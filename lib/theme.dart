import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Colors.teal;
  static const Color accentColor = Colors.orangeAccent;

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.openSans(
      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87,
    ),
    displayMedium: GoogleFonts.openSans(
      fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87,
    ),
    titleMedium: GoogleFonts.openSans(
      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87,
    ),
    bodyLarge: GoogleFonts.openSans(fontSize: 16, color: Colors.black87),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.black54),
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: _textTheme.displayMedium?.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: _textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(88, 48),
      ),
    ),
  );
}
