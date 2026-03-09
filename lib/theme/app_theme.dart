import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimary = Color(0xFFA9B7AA);
const Color kPrimaryLight = Color(0xFFD4DED5);
const Color kPrimaryDark = Color(0xFF7A9A7C);
const Color kBackgroundLight = Color(0xFFF7F7F7);
const Color kBackgroundDark = Color(0xFF181A18);
const Color kSurfaceLight = Color(0xFFFFFFFF);
const Color kSurfaceDark = Color(0xFF252825);

// Shared text theme built from Google Fonts
TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: GoogleFonts.notoSerifTc(
        textStyle: base.displayLarge, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.notoSerifTc(
        textStyle: base.displayMedium, fontWeight: FontWeight.w700),
    headlineLarge: GoogleFonts.notoSerifTc(
        textStyle: base.headlineLarge, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.notoSerifTc(
        textStyle: base.headlineMedium, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.notoSerifTc(
        textStyle: base.titleLarge, fontWeight: FontWeight.w700),
    bodyLarge: GoogleFonts.notoSansTc(textStyle: base.bodyLarge),
    bodyMedium: GoogleFonts.notoSansTc(textStyle: base.bodyMedium),
    bodySmall: GoogleFonts.notoSansTc(textStyle: base.bodySmall),
    labelLarge: GoogleFonts.notoSansTc(
        textStyle: base.labelLarge, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.notoSansTc(textStyle: base.labelSmall),
  );
}

class AppTheme {
  AppTheme._();

  static final ThemeData light = () {
    final base = ThemeData(brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.light,
        primary: kPrimary,
        surface: kBackgroundLight,
        onSurface: const Color(0xFF1A1C1A),
      ),
      textTheme: _buildTextTheme(base.textTheme),
      scaffoldBackgroundColor: kBackgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1C1A)),
        titleTextStyle: GoogleFonts.notoSerifTc(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1C1A),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.95),
        indicatorColor: kPrimary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return GoogleFonts.notoSerifTc(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? kPrimary : const Color(0xFF8A8E8A),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: isSelected ? kPrimary : const Color(0xFF8A8E8A),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: kPrimary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: kPrimary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.notoSansTc(color: Colors.grey.shade400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.notoSansTc(
              fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: kPrimary.withOpacity(0.15)),
        ),
      ),
    );
  }();

  static final ThemeData dark = () {
    final base = ThemeData(brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.dark,
        primary: kPrimary,
        surface: kBackgroundDark,
        onSurface: const Color(0xFFE2E6E2),
      ),
      textTheme: _buildTextTheme(base.textTheme),
      scaffoldBackgroundColor: kBackgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: kBackgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFE2E6E2)),
        titleTextStyle: GoogleFonts.notoSerifTc(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFE2E6E2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kSurfaceDark.withOpacity(0.95),
        indicatorColor: kPrimary.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return GoogleFonts.notoSerifTc(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? kPrimary : const Color(0xFF8A8E8A),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: isSelected ? kPrimary : const Color(0xFF8A8E8A),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: kPrimary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: kPrimary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF6A6E6A)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: const Color(0xFF1A1C1A),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.notoSansTc(
              fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: kPrimary.withOpacity(0.15)),
        ),
      ),
    );
  }();
}

// Text style helpers (using google_fonts)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayWord => GoogleFonts.notoSerifTc(
      fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1);

  static TextStyle get headingLarge => GoogleFonts.notoSerifTc(
      fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5);

  static TextStyle get headingMedium =>
      GoogleFonts.notoSerifTc(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle get morphemeTitle =>
      GoogleFonts.notoSerifTc(fontSize: 20, fontWeight: FontWeight.w700);

  static TextStyle get bodyLarge =>
      GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium =>
      GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get caption => GoogleFonts.notoSansTc(
      fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle get label => GoogleFonts.notoSerifTc(
      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5);
}
