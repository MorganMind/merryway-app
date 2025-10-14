import 'package:flutter/material.dart';

/// Design tokens for the Merryway redesign
/// Based on the comprehensive UI specification
class RedesignTokens {
  // ===== COLORS =====
  
  // Text colors
  static const Color ink = Color(0xFF14181D);           // Primary text (body)
  static const Color slate = Color(0xFF2A3037);         // Secondary text/icons
  static const Color mutedText = Color(0xFF64707D);     // Tertiary text
  
  // Background colors
  static const Color canvas = Color(0xFFFAF8F3);        // Page background (warm cream)
  static const Color cardSurface = Color(0xFFFFFFFF);   // Card surface (use with 96% opacity)
  static const Color divider = Color(0xFFE8E6E1);       // Divider lines
  
  // Primary colors (Deep Navy - quiet, premium, sophisticated)
  static const Color primary = Color(0xFF1B2A41);       // Primary actions, CTAs
  static const Color primaryHover = Color(0xFF152235);  // Hover state
  static const Color primaryPressed = Color(0xFF0F1A27); // Pressed state
  static const Color onPrimary = Color(0xFFFFFFFF);     // Text on primary background
  static const Color primaryDisabled = Color(0xFF8FA1B8); // Disabled state
  
  // Accent colors
  static const Color sparkle = Color(0xFFC9A24A);       // Sparkle accent (small moments only)
  static const Color accentSage = Color(0xFF7BA89A);    // Secondary accent (legacy)
  
  // Legacy compatibility (for gradual migration)
  static const Color accentGold = sparkle;              // Alias for sparkle
  
  // Pill backgrounds
  static const Color infoPillBg = Color(0xFFE8EEF5);    // Info pills
  static const Color successPillBg = Color(0xFFE7F4EC); // Success pills
  static const Color dangerPillBg = Color(0xFFFDECEC);  // Danger pills
  static const Color dangerColor = Color(0xFFCC4B4B);   // Danger text/icons
  
  // ===== ELEVATION & SHADOWS =====
  
  // Level 0: No shadow
  static const List<BoxShadow> shadowNone = [];
  
  // Level 1: Cards
  static const List<BoxShadow> shadowLevel1 = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
      color: Color(0x0F000000), // rgba(0,0,0,0.06)
    ),
  ];
  
  // Level 2: Sticky bars/sheets
  static const List<BoxShadow> shadowLevel2 = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
      color: Color(0x19000000), // rgba(0,0,0,0.10)
    ),
  ];
  
  // ===== BORDER RADII =====
  
  static const double radiusCard = 24.0;          // Cards/containers
  static const double radiusPill = 999.0;         // Pills/chips (full round)
  static const double radiusButton = 14.0;        // Buttons/inputs
  
  // ===== SPACING SCALE =====
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  
  // Page gutters
  static const double gutterMobile = 24.0;
  static const double gutterDesktop = 32.0;
  
  // ===== TYPOGRAPHY =====
  // Using system-ui/Inter family, lining numerals
  
  // Title/Large - 22px, 600 weight (card titles)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.3,
  );
  
  // Title/Medium - 20px, 600 weight (subsection headings)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.3,
  );
  
  // Title/Small - 18px, 600 weight (section headings)
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.3,
  );
  
  // Body - 16px, 400 weight (descriptions)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ink,
    height: 1.5,
  );
  
  // Meta - 14px, 500 weight (pills, small labels)
  static const TextStyle meta = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: slate,
    height: 1.4,
  );
  
  // Caption - 12-13px, 500 weight (date badges, helper text)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: mutedText,
    height: 1.3,
  );
  
  // Button - 16px, 600 weight (CTAs)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
  
  // ===== HELPER METHODS =====
  
  /// Card surface with 96% opacity
  static Color get cardSurfaceWithOpacity => cardSurface.withOpacity(0.96);
  
  /// Get gutter size based on screen width
  static double getGutter(double screenWidth) {
    return screenWidth < 768 ? gutterMobile : gutterDesktop;
  }
  
  /// Feedback bar background with blur
  static Color feedbackBarBg(Brightness brightness) {
    return brightness == Brightness.light
        ? Colors.white.withOpacity(0.88)
        : const Color(0xFF14181D).withOpacity(0.72);
  }
}

