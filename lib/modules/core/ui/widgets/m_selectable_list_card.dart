import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

// Data class for list items
class MSelectableListItem {
  final String id;
  final String title;
  final String description;
  final Object icon;
  final String? tag;
  final Object? value;

  const MSelectableListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.tag,
    this.value,
  });
}

class MSelectableListCard extends StatefulWidget {
  final String title;
  final String description;
  final List<MSelectableListItem> items;
  final String? selectedItemId;
  final Function(MSelectableListItem item) onItemSelected;

  const MSelectableListCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    this.selectedItemId,
    required this.onItemSelected,
  });

  @override
  State<MSelectableListCard> createState() => _MSelectableListCardState();
}

class _MSelectableListCardState extends State<MSelectableListCard> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return ShadCard(
      padding: sl<LayoutBloc>().state.layoutType == LayoutType.mobile 
            ? const EdgeInsets.all(16)
            : const EdgeInsets.all(24),
      backgroundColor: colors.background,
      border: Border.all(color: colors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.h3.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description,
            style: theme.textTheme.muted.copyWith(
              fontSize: 12,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.items.map((item) => _buildListItem(item)),
        ],
      ),
    );
  }

  Widget _buildListItem(MSelectableListItem item) {
    return _HoverableListItem(
      item: item,
      isSelected: item.id == widget.selectedItemId,
      onTap: () => widget.onItemSelected(item),
    );
  }
}

class _HoverableListItem extends StatefulWidget {
  final MSelectableListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverableListItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverableListItem> createState() => _HoverableListItemState();
}

class _HoverableListItemState extends State<_HoverableListItem> {
  final LayoutBloc layoutBloc = sl<LayoutBloc>();
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isHighlighted = _isHovered || widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? colors.secondary : colors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon
              ShadImage(
                widget.item.icon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isHighlighted ? colors.secondaryForeground : colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.description,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 14,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Optional Tag
              if (layoutBloc.state.layoutType != LayoutType.mobile && widget.item.tag != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.item.tag!,
                    style: theme.textTheme.p.copyWith(
                      fontSize: 12,
                      color: colors.primaryForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 