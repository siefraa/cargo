import 'package:flutter/material.dart';

// ── Industrial Dark Theme — China Freight ──
class AppColors {
  // Deep navy base
  static const navy     = Color(0xFF0A1628);
  static const navyMid  = Color(0xFF112240);
  static const navyLight= Color(0xFF1D3461);
  static const steel    = Color(0xFF2A4A7F);

  // China red accent
  static const chinaRed  = Color(0xFFDE2910);
  static const redLight  = Color(0xFFFF4D3D);
  static const redDeep   = Color(0xFFB01E0E);

  // Gold accent (prosperity)
  static const gold     = Color(0xFFFCBF49);
  static const goldDeep = Color(0xFFE8A820);

  // Cargo/industrial
  static const cargo    = Color(0xFF3D5A80);
  static const rust     = Color(0xFFB5451B);
  static const concrete = Color(0xFF6B7C93);

  // Status colors
  static const statusInTransit  = Color(0xFF0EA5E9);
  static const statusCleared    = Color(0xFF10B981);
  static const statusPending    = Color(0xFFF59E0B);
  static const statusHeld       = Color(0xFFEF4444);
  static const statusDelivered  = Color(0xFF6366F1);

  // Surface
  static const surface     = Color(0xFF152035);
  static const surfaceCard = Color(0xFF1A2942);
  static const surfaceDark = Color(0xFF0D1B2E);

  // Text
  static const textPrimary   = Color(0xFFE8F0FE);
  static const textSecondary = Color(0xFF8FA3BF);
  static const textMuted     = Color(0xFF4A6080);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.chinaRed,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyMid,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF1E3A5F), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.chinaRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyMid,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.chinaRed, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textSecondary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navyMid,
      indicatorColor: AppColors.chinaRed.withOpacity(0.2),
      iconTheme: const WidgetStatePropertyAll(IconThemeData(color: AppColors.textSecondary)),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF1E3A5F), thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.navyLight,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide.none,
    ),
  );
}
