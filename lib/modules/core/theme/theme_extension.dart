import 'package:flutter/material.dart';
import 'package:app/modules/core/theme/theme_colors.dart';

// This is a theme extension - it lets us add custom properties to ThemeData
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color white;
  final Color black;
  final Color background;
  final Color foreground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color input;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color cyan;
  final Color gold;

  AppThemeExtension({
    required this.white,
    required this.black,
    required this.background,
    required this.foreground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.input,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.cyan,
    required this.gold,
  });

  // Create light theme colors
  factory AppThemeExtension.light() => AppThemeExtension(
        white: ThemeColors.white.light,
        black: ThemeColors.black.light,
        background: ThemeColors.background.light,
        foreground: ThemeColors.foreground.light,
        muted: ThemeColors.muted.light,
        mutedForeground: ThemeColors.mutedForeground.light,
        border: ThemeColors.border.light,
        input: ThemeColors.input.light,
        primary: ThemeColors.primary.light,
        primaryForeground: ThemeColors.primaryForeground.light,
        secondary: ThemeColors.secondary.light,
        secondaryForeground: ThemeColors.secondaryForeground.light,
        cyan: ThemeColors.cyan.light,
        gold: ThemeColors.gold.light,
      );

  // Create dark theme colors
  factory AppThemeExtension.dark() => AppThemeExtension(
        white: ThemeColors.white.dark,
        black: ThemeColors.black.dark,
        background: ThemeColors.background.dark,
        foreground: ThemeColors.foreground.dark,
        muted: ThemeColors.muted.dark,
        mutedForeground: ThemeColors.mutedForeground.dark,
        border: ThemeColors.border.dark,
        input: ThemeColors.input.dark,
        primary: ThemeColors.primary.dark,
        primaryForeground: ThemeColors.primaryForeground.dark,
        secondary: ThemeColors.secondary.dark,
        secondaryForeground: ThemeColors.secondaryForeground.dark,
        cyan: ThemeColors.cyan.dark,
        gold: ThemeColors.gold.dark,
      );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? white,
    Color? black,
    Color? background,
    Color? foreground,
    Color? muted,
    Color? mutedForeground,
    Color? border,
    Color? input,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? cyan,
    Color? gold,
  }) {
    return AppThemeExtension(
      white: white ?? this.white,
      black: black ?? this.black,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      cyan: cyan ?? this.cyan,
      gold: gold ?? this.gold,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(primaryForeground, other.primaryForeground, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground: Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

// Helper extension to make accessing the theme extension easier
extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;
} 