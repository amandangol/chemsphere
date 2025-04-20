// Add this to theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0C54B0), // Deeper blue - more scientific
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD8E6FF), // Lighter blue container
        onPrimaryContainer: Color(0xFF0A3670),
        secondary: Color(0xFF00875A), // More muted green
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFCCEFE2), // Lighter green container
        onSecondaryContainer: Color(0xFF005437),
        tertiary: Color(0xFF8126A0), // More muted purple
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFE8D5F2), // Lighter purple container
        onTertiaryContainer: Color(0xFF4A1464),
        error: Color(0xFFD03A2B), // Slightly muted red
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF222222),
        surfaceContainerHighest: Color(0xFFF8F8F8),
        onSurfaceVariant: Color(0xFF666666),
        outline: Color(0xFFE5E5E5),
        shadow: Color(0x14000000),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge:
            GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium:
            GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge:
            GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge:
            GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium:
            GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        titleSmall:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal),
        bodyMedium:
            GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.normal),
        bodySmall:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge:
            GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        labelMedium:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF0C54B0),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0C54B0),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F7FA),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF222222),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: Color(0xFF0C54B0),
        unselectedItemColor: Color(0xFF666666),
        backgroundColor: Colors.transparent,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        activeTrackColor: Color(0xFF0C54B0),
        inactiveTrackColor: Color(0xFFD8E6FF),
        thumbColor: Color(0xFF0C54B0),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? const Color(0xFF0C54B0)
              : Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? const Color(0xFFD8E6FF)
              : const Color(0xFFE5E5E5);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? const Color(0xFF0C54B0)
              : Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF0C54B0), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? const Color(0xFF0C54B0)
              : const Color(0xFF666666);
        }),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
