import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MerryWayTheme {
  // Warm, soft color palette inspired by Mary Poppins and storybooks
  static const Color primaryWarmPink = Color(0xFFF4A6B8);
  static const Color primarySoftBlue = Color(0xFFB4D7E8);
  static const Color accentGolden = Color(0xFFE5C17D);
  static const Color accentLavender = Color(0xFFD9B9E0);

  static const Color softBg = Color(0xFFFAF7F4);
  static const Color warmWhite = Color(0xFFFEF9F6);
  static const Color textDark = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF8B8B8B);

  // Magic touches - whimsical quotes from Option 1
  static const List<String> magicTouches = [
    "Remember, the secret ingredient is always love! 💕",
    "Every moment together is a treasure 🌟",
    "You're making memories that will last forever ✨",
    "The magic happens when you're all together 🌈",
    "Practically perfect in every way! 🎩",
    "A spoonful of fun makes everything better 🥄",
    "Let your imagination lead the way 🦄",
    "The best adventures happen at home 🏡",
    "Connection is the most magical activity of all 💝",
    "Trust your instincts - you know your family best! 🎭",
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Primary colors
    colorScheme: const ColorScheme.light(
      primary: primarySoftBlue,
      onPrimary: Colors.white,
      secondary: primaryWarmPink,
      onSecondary: Colors.white,
      tertiary: accentGolden,
      surface: softBg,
      onSurface: textDark,
    ),

    scaffoldBackgroundColor: warmWhite,

    // Typography - Space Grotesk for all text
    textTheme: TextTheme(
      // Display (large titles) - Using Space Grotesk
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),

      // Headline (section titles) - Space Grotesk
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),

      // Body (regular text) - Space Grotesk for body
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),

      // Label (buttons, small interactive text) - Space Grotesk
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      ),
    ),

    // Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySoftBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),

    // Input field styling
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primarySoftBlue, width: 2),
      ),
      labelStyle: const TextStyle(
        color: textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Card styling
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),
  );
}

