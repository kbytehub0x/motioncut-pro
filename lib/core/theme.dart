import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0F0F12);
  static const Color surface = Color(0xFF18181D);
  static const Color surfaceElevated = Color(0xFF22222B);
  static const Color surfaceHighlight = Color(0xFF2E2E3A);
  
  static const Color primary = Color(0xFFFF2A6D); // Cyber Rose (CapCut / Alight vibe)
  static const Color primaryLight = Color(0xFFFF6584);
  static const Color accent = Color(0xFF05D9E8); // Cyan Glow
  static const Color accentOrange = Color(0xFFFF8B26); // Amber Warning
  static const Color success = Color(0xFF00E676);
  static const Color divider = Color(0xFF262633);

  // Track Specific Colors
  static const Color videoTrackColor = Color(0xFF26324D);
  static const Color videoClipColor = Color(0xFF334A7B);
  static const Color audioTrackColor = Color(0xFF233B2B);
  static const Color audioClipColor = Color(0xFF2E633C);
  static const Color textTrackColor = Color(0xFF4A3423);
  static const Color textClipColor = Color(0xFF7E5434);
  static const Color overlayClipColor = Color(0xFF5B2B63);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceElevated,
        thumbColor: Colors.white,
        overlayColor: Color(0x33FF2A6D),
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
        bodySmall: TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
      useMaterial3: true,
    );
  }
}
