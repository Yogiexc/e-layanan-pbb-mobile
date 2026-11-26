import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Surakarta Royal Crimson & Banking Elegance
  static const Color primary = Color(0xFF8B121A); // Deep Royal Crimson
  static const Color primaryDeep = Color(0xFF5A080E); // Midnight Maroon
  static const Color primaryLight = Color(0xFFBA222C); // Vibrant Crimson
  static const Color primarySoft = Color(0xFFFBF1F2); // Soft Tint
  static const Color accentGold = Color(0xFFD49E35); // Keraton Metallic Gold
  static const Color accentGoldLight = Color(0xFFF9F1DC); // Soft Gold Champagne

  // Light Theme Palette (Clean, High-end Neo-Banking)
  static const Color bgLight = Color(0xFFF6F7F9); // Studio Warm Gray
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtleLight = Color(0xFFF0F2F5);
  static const Color borderLight = Color(0xFFE4E7EC);
  static const Color textPrimaryLight = Color(0xFF101828); // Slate 900
  static const Color textSecondaryLight = Color(0xFF667085); // Slate 500
  static const Color textTertiaryLight = Color(0xFF98A2B3); // Slate 400

  // Dark Theme Palette (Executive Obsidian)
  static const Color bgDark = Color(0xFF0C0E12); // Deep Obsidian
  static const Color surfaceDark = Color(0xFF151921); // Charcoal Slate
  static const Color surfaceSubtleDark = Color(0xFF1E232E);
  static const Color borderDark = Color(0xFF282F3D);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Status Colors (Refined Fintech)
  static const Color statusPendingText = Color(0xFFB45309);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingBorder = Color(0xFFFDE68A);

  static const Color statusRejectedText = Color(0xFFB91C1C);
  static const Color statusRejectedBg = Color(0xFFFEE2E2);
  static const Color statusRejectedBorder = Color(0xFFFECACA);

  static const Color statusApprovedText = Color(0xFF047857);
  static const Color statusApprovedBg = Color(0xFFD1FAE5);
  static const Color statusApprovedBorder = Color(0xFFA7F3D0);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: textPrimaryLight,
      displayColor: textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accentGold,
        onSecondary: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        error: statusRejectedText,
        outline: borderLight,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bgLight,
        foregroundColor: textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: textPrimaryLight,
          side: const BorderSide(color: borderLight, width: 1.2),
          backgroundColor: surfaceLight,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textSecondaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusRejectedText),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: surfaceLight,
        elevation: 0,
        indicatorColor: primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : textSecondaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : textSecondaryLight,
            size: 22,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: textPrimaryDark,
      displayColor: textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEF5350),
        onPrimary: Colors.white,
        secondary: Color(0xFFFBBF24),
        onSecondary: Color(0xFF2E1A00),
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        error: Color(0xFFF87171),
        outline: borderDark,
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bgDark,
        foregroundColor: textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: textPrimaryDark,
          side: const BorderSide(color: borderDark, width: 1.2),
          backgroundColor: surfaceDark,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textSecondaryDark,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF6B7280),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: surfaceDark,
        elevation: 0,
        indicatorColor: const Color(0xFFEF5350).withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xFFEF5350) : textSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? const Color(0xFFEF5350) : textSecondaryDark,
            size: 22,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
