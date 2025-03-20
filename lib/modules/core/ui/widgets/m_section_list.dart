import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class MSectionListItem {
  final String id;
  final String label;
  final String? iconUrl;
  final IconData? iconData;

  const MSectionListItem({
    required this.id,
    required this.label,
    this.iconUrl,
    this.iconData,
  });
}

typedef MSectionListItemCallback = void Function(MSectionListItem item);

class MSectionList extends StatelessWidget {
  final String title;
  final List<MSectionListItem> items;
  final MSectionListItemCallback onItemSelected;
  final String? selectedItemId;

  const MSectionList({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    this.selectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: theme.textTheme.h4.copyWith(
              fontSize: 16,
              color: colors.foreground,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item.id == selectedItemId;
            
            return _ListItem(
              item: item,
              isSelected: isSelected,
              onTap: () => onItemSelected(item),
            );
          },
        ),
      ],
    );
  }
}

class _ListItem extends StatefulWidget {
  final MSectionListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ListItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isSelected || isHovered ? colors.secondary : colors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              if (widget.item.iconUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ShadImage(
                    widget.item.iconUrl!,
                    width: 20,
                    height: 20,
                  ),
                )
              else if (widget.item.iconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    widget.item.iconData,
                    size: 20,
                    color: colors.mutedForeground,
                  ),
                ),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: theme.textTheme.p.copyWith(
                    color: widget.isSelected ? colors.secondaryForeground : colors.foreground,
                    fontSize: 13
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 