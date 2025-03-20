import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IconButton extends StatefulWidget {
  final String iconUrl;
  final double? size;
  final VoidCallback? onTap;

  const IconButton({
    super.key,
    required this.iconUrl,
    this.size,
    this.onTap,
  });

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _isHovered ? (widget.size ?? 28) + 2 : (widget.size ?? 28);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: ShadImage(
                widget.iconUrl,
                width: 20,
                height: 20,
              ),
          ),
        ),
      ),
    );
  }
} 