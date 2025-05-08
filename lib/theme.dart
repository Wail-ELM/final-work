import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette pastel
  static const Color pastelBlue     = Color(0xFFE3F2FD);
  static const Color pastelMint     = Color(0xFFE8F5E9);
  static const Color pastelLavender = Color(0xFFF3E5F5);
  static const Color pastelCoral    = Color(0xFFFFCCBC);
  static const Color pastelGold     = Color(0xFFFFF9C4);
  static const Color darkGrayText   = Color(0xFF37474F);

  // Typographie
  static final TextTheme textTheme = TextTheme(
    headlineLarge: GoogleFonts.roboto(
      fontSize: 28, fontWeight: FontWeight.w600, color: darkGrayText),
    headlineMedium: GoogleFonts.roboto(
      fontSize: 22, fontWeight: FontWeight.w600, color: darkGrayText),
    bodyLarge: GoogleFonts.openSans(
      fontSize: 16, fontWeight: FontWeight.w400, color: darkGrayText),
    titleMedium: GoogleFonts.openSans(
      fontSize: 14, fontWeight: FontWeight.w500, color: darkGrayText),
  );

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: pastelBlue,
      primaryColor: pastelMint,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: pastelBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGrayText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: pastelCoral,
        unselectedItemColor: Colors.black38,
        showUnselectedLabels: true,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelCoral,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: textTheme.titleMedium,
        hintStyle: textTheme.bodyLarge,
      ),
    );
  }
}
