import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.gradientStart,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.gradientStart,
            secondary: AppColors.accent,
            surface: Colors.white,
          ),
      textTheme: GoogleFonts.notoSansTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        titleTextStyle: GoogleFonts.notoSans(
          color: AppColors.primaryDark,
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.gradientStart,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gradientStart.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.notoSans(
          color: AppColors.gradientStart,
          fontSize: AppFontSizes.small,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        side: BorderSide.none,
      ),
    );
  }

  // === THEME TOI ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.gradientStart,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.gradientStart,
            secondary: AppColors.accent,
            surface: AppColors.primaryDark,
          ),
      scaffoldBackgroundColor: AppColors.primaryDark,
      textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.notoSans(
          color: Colors.white,
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryMid,
        selectedItemColor: AppColors.gradientStart,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gradientStart.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.notoSans(
          color: AppColors.gradientStart,
          fontSize: AppFontSizes.small,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
