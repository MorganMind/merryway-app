import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/user/models/user_settings.dart' as u;
import 'package:app/modules/core/theme/theme_extension.dart';

class ThemeProvider extends InheritedWidget {
  final u.ThemeMode currentTheme;
  final Key themeKey;

  ThemeProvider({
    super.key,
    required this.currentTheme,
    required super.child,
  }) : themeKey = ValueKey(currentTheme);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  ShadThemeData get theme {
    final isDark = currentTheme == u.ThemeMode.dark;
    
    return ShadThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark ? ShadZincColorScheme.dark() : ShadZincColorScheme.light(),
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
      extensions: [
        isDark ? AppThemeExtension.dark() : AppThemeExtension.light(),
      ],
    );
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
} 