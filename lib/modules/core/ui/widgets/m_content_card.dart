import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class MContentCard extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final Size? size;
  final IconData? defaultIcon;
  final VoidCallback? onPressed;

  const MContentCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.size,
    this.defaultIcon = LucideIcons.file,
    this.onPressed,
  });

  @override
  State<MContentCard> createState() => _MContentCardState();
}

class _MContentCardState extends State<MContentCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return GestureDetector(
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: ShadCard(
          width: widget.size?.width,
          padding: EdgeInsets.zero,
          border: Border.all(
            color: isHovered ? colors.border : Colors.transparent,
            width: 1,
          ),
          shadows: [],
          backgroundColor: colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.subtitle,
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  color: colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final colors = context.appTheme;
    
    if (widget.imageUrl == null) {
      // Show centered icon when no image
      return Container(
        width: widget.size?.width,
        height: widget.size != null ? widget.size!.height - 76 : null, // Account for text rows height
        color: colors.muted.withOpacity(0.2),
        child: Center(
          child: Icon(
            widget.defaultIcon,
            size: 100,
            color: colors.mutedForeground,
          ),
        ),
      );
    }

    Widget imageWidget;
    
    // Check if the URL is an asset path or a network URL
    if (widget.imageUrl!.startsWith('assets/')) {
      if (widget.imageUrl!.endsWith('.svg')) {
        imageWidget = ShadImage(
          widget.imageUrl!, 
          fit: BoxFit.cover
        );
      } else {
        imageWidget = Image.asset(
          widget.imageUrl!,
          fit: BoxFit.cover,
        );
      }
    } else {
      imageWidget = Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to centered icon if network image fails to load
          return Container(
            color: colors.muted.withOpacity(0.2),
            child: Center(
              child: Icon(
                widget.defaultIcon,
                size: 100,
                color: colors.mutedForeground,
              ),
            ),
          );
        },
      );
    }

    if (widget.size != null) {
      // Fixed size image
      return SizedBox(
        width: widget.size!.width,
        height: widget.size!.height - 76, // Account for text rows height
        child: imageWidget,
      );
    } else {
      // Image determines size
      return imageWidget;
    }
  }
} 