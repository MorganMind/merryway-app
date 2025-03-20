import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/user/models/user_settings.dart' as u;
import 'package:flutter/material.dart';

class ThemeModeSelector extends StatelessWidget {
  final u.ThemeMode selectedTheme;
  final Function(u.ThemeMode) onSelect;


  const ThemeModeSelector({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose the appearance of Morgan',
          style: TextStyle(
            fontSize: 14,
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildThemeOption(
              type: u.ThemeMode.light,
              label: 'Light Mode',
              image: 'assets/img/light.png', 
              isMobile: isMobile,
            ),
            const SizedBox(width: 32),
            _buildThemeOption(
              type: u.ThemeMode.dark,
              label: 'Dark Mode',
              image: 'assets/img/dark.png',
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required u.ThemeMode type,
    required String label,
    required String image,
    bool isMobile = false,
  }) {
    final isSelected = selectedTheme == type;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 138 : 208,
              height: isMobile ? 117 : 178,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 