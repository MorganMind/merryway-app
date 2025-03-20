import 'package:app/modules/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/modules/user/models/user_settings.dart' as u;

class ThemeColors {
  static const white = ColorGroup(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFFFFFFFF),
  );

  static const black = ColorGroup(
    light: Color(0xFF18181B),
    dark: Color(0xFF18181B),
  );

  static const background = ColorGroup(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF18181B),
  );

  static const foreground = ColorGroup(
    light: Color(0xFF18181B),
    dark: Color(0xFFFFFFFF),
  );

  static const muted = ColorGroup(
    light: Color(0xFFF4F4F5),
    dark: Color(0xFF27272A),
  );

  static const mutedForeground = ColorGroup(
    light: Color(0xFF71717A),
    dark: Color(0xFFA1A1AA),
  );

  static const border = ColorGroup(
    light: Color(0xFFE4E4E7),
    dark: Color(0xFF27272A),
  );

  static const input = ColorGroup(
    light: Color(0xFFE4E4E7),
    dark: Color(0xFF27272A),
  );

  static const primary = ColorGroup(
    light: Color(0xFF18181B),
    dark: Color(0xFFFFFFFF),
  );

  static const primaryForeground = ColorGroup(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF18181B),
  );

  static const secondary = ColorGroup(
    light: Color(0xFFF4F4F5),
    dark: Color(0xFF27272A),
  );

  static const secondaryForeground = ColorGroup(
    light: Color(0xFF18181B),
    dark: Color(0xFFFFFFFF),
  );

  static const cyan = ColorGroup(
    light: Color(0xFF32ADE6),
    dark: Color(0xFF32ADE6),
  );

  static const gold = ColorGroup(
    light: Color(0xFFE8C468),
    dark: Color(0xFFE8C468),
  );

}

class ColorGroup {
  final Color light;
  final Color dark;

  const ColorGroup({
    required this.light,
    required this.dark,
  });

  Color getValue(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    return themeProvider.currentTheme == u.ThemeMode.dark ? dark : light;
  }
} 