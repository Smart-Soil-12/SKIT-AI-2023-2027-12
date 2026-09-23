import 'package:flutter/material.dart';

/// AppTheme containing color constants used across dashboard widgets.
class AppTheme {
  const AppTheme._();

  static const Color primaryGreen = Color(0xFF0B6638);
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF074324);
  static const Color creamBackground = Color(0xFFF7FAF7);

  static const Color statusOptimal = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusCritical = Color(0xFFD32F2F);
  static const Color statusNeutral = Color(0xFF757575);

  static ThemeData get lightTheme => SmartSoilTheme.lightTheme;
}

/// Smart Soil Material 3 Agricultural Theme
class SmartSoilTheme {
  const SmartSoilTheme._();

  static const Color forestGreen = Color(0xFF0B6638);
  static const Color darkGreen = Color(0xFF074324);
  static const Color emeraldGreen = Color(0xFF2E7D32);
  static const Color mintAccent = Color(0xFFA5D6A7);
  static const Color creamBackground = Color(0xFFF7FAF7);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1B2A1E);
  static const Color textMuted = Color(0xFF5A6E5F);
  static const Color alertRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color infoBlue = Color(0xFF0277BD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestGreen,
        primary: forestGreen,
        onPrimary: Colors.white,
        secondary: emeraldGreen,
        onSecondary: Colors.white,
        surface: creamBackground,
        onSurface: textDark,
        error: alertRed,
      ),
      scaffoldBackgroundColor: creamBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardSurface,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardSurface,
        indicatorColor: forestGreen.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: forestGreen,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
      ),
    );
  }
}
