import 'package:flutter/material.dart';

abstract final class CutZeroColors {
  static const sky = Color(0xFF2A9FC3);
  static const skyDark = Color(0xFF167A9A);
  static const ink = Color(0xFF123541);
  static const canvas = Color(0xFFF4F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const mint = Color(0xFF41A882);
  static const coral = Color(0xFFE46F67);
  static const amber = Color(0xFFF4C15D);
  static const line = Color(0xFFD4E3E7);
}

abstract final class CutZeroTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: CutZeroColors.sky,
      brightness: Brightness.light,
      primary: CutZeroColors.skyDark,
      secondary: CutZeroColors.mint,
      error: CutZeroColors.coral,
      surface: CutZeroColors.surface,
    );
    final textTheme = ThemeData.light().textTheme.apply(
      bodyColor: CutZeroColors.ink,
      displayColor: CutZeroColors.ink,
      fontFamily: 'sans-serif',
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: CutZeroColors.canvas,
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: CutZeroColors.surface,
        foregroundColor: CutZeroColors.ink,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: CutZeroColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: CutZeroColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: const BorderSide(color: CutZeroColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: CutZeroColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: CutZeroColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: CutZeroColors.line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: CutZeroColors.surface,
        indicatorColor: Color(0xFFDDF2F8),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: CutZeroColors.surface,
        indicatorColor: Color(0xFFDDF2F8),
        useIndicator: true,
      ),
      dividerColor: CutZeroColors.line,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CutZeroColors.skyDark,
        linearTrackColor: Color(0xFFDDECEF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CutZeroColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    );
  }
}
