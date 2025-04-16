// Add this to theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0F60C4), // Deep blue for chemistry
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFCEE2FF),
        onPrimaryContainer: Color(0xFF0D3B69),
        secondary: Color(0xFF00A86B), // Green for organic chemistry
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFBCF4E0),
        onSecondaryContainer: Color(0xFF00573A),
        tertiary: Color(0xFF9C27B0), // Purple for lab experiments
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFE9C7F0),
        onTertiaryContainer: Color(0xFF4A148C),
        error: Color(0xFFE53935),
        onError: Colors.white,
        background: Colors.white,
        onBackground: Color(0xFF1A1A1A),
        surface: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        surfaceVariant: Color(0xFFF5F5F5),
        onSurfaceVariant: Color(0xFF757575),
        outline: Color(0xFFE0E0E0),
        shadow: Color(0x1A000000),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF0F60C4),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF0F60C4),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F7FA),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1A1A1A),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: Color(0xFF0F60C4),
        unselectedItemColor: Color(0xFF757575),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
