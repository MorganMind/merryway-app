import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/enums/avatar_type.dart';

class AvatarTypeSelector extends StatelessWidget {
  final AvatarType selectedType;
  final Function(AvatarType) onSelect;

  const AvatarTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return ShadCard(
      width: 415,
      backgroundColor: colors.background,
      border: Border.all(color: colors.border),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: theme.textTheme.h3.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This determines how you will appear around the app',
              style: TextStyle(
                fontSize: 14,
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAvatarOption(
                  type: AvatarType.upload,
                  label: 'Upload',
                  icon: Icons.person,
                ),
                const SizedBox(width: 16),
                _buildAvatarOption(
                  type: AvatarType.caricature,
                  label: 'Caricature',
                  icon: Icons.face,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required AvatarType type,
    required String label,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) {
        final colors = context.appTheme;
        final isSelected = selectedType == type;
        final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;
        bool isHovered = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: GestureDetector(
                  onTap: () => onSelect(type),
                  child: Container(
                    padding: isMobile ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isHovered ? colors.secondary : colors.background,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.border,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 24,
                            color: isSelected ? colors.primary : colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? colors.primary : colors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            );  
          },
        );
      },
    );
  }
} 