import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class SquareAgentButton extends StatefulWidget {
  final Object icon = 'assets/img/morgan_avatar.png';
  final bool isSelected;
  final VoidCallback? onTap;

  const SquareAgentButton({
    super.key,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<SquareAgentButton> createState() => _SquareAgentButtonState();
}

class _SquareAgentButtonState extends State<SquareAgentButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;
    final buttonSize = isActive ? 48.0 : 44.0;
    final colors = context.appTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(isActive ? 8 : 12),
            border: Border.all(
              color: isActive ? colors.foreground : colors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.6,
                  child: ShadImage(
                    widget.icon,
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
} 