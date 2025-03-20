import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

// Data model for list items
class MSimpleListItem {
  final String id;
  final String name;
  final String description;
  final Object icon;

  MSimpleListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class MSimpleListCard extends StatefulWidget {
  final String title;
  final String description;
  final List<MSimpleListItem> items;
  final Function(String id) onItemDeleted;
  final Function(MSimpleListItem item) onItemClick;

  const MSimpleListCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.onItemDeleted,
    required this.onItemClick,
  });

  @override
  State<MSimpleListCard> createState() => _MSimpleListCardState();
}

class _MSimpleListCardState extends State<MSimpleListCard> {
  final Map<String, ShadPopoverController> _popoverControllers = {};
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for initial items
    for (var item in widget.items) {
      _popoverControllers[item.id] = ShadPopoverController();
    }
  }

  @override
  void didUpdateWidget(MSimpleListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Add controllers for new items
    for (var item in widget.items) {
      if (!_popoverControllers.containsKey(item.id)) {
        _popoverControllers[item.id] = ShadPopoverController();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all popover controllers
    for (var controller in _popoverControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<MSimpleListItem> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.items.length);
    return widget.items.sublist(startIndex, endIndex);
  }

  String get _paginationText {
    final startIndex = (_currentPage * _itemsPerPage) + 1;
    final endIndex = ((_currentPage + 1) * _itemsPerPage)
        .clamp(0, widget.items.length);
    return '$startIndex-$endIndex of ${widget.items.length} ${widget.title.toLowerCase()}';
  }

  String get _mobilePaginationText {
    final startIndex = (_currentPage * _itemsPerPage) + 1;
    final endIndex = ((_currentPage + 1) * _itemsPerPage)
        .clamp(0, widget.items.length);
    return '$startIndex-$endIndex of ${widget.items.length}';
  }

  bool get _canGoNext =>
      (_currentPage + 1) * _itemsPerPage < widget.items.length;

  bool get _canGoPrevious => _currentPage > 0;

  void _nextPage() {
    if (_canGoNext) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_canGoPrevious) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

    return ShadCard(
      padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
      backgroundColor: colors.background,
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

          Container(
            height: isMobile ? 5 * 64 : 5 * 73, // Each item is 64px (16px padding top/bottom + 32px content height)
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ..._currentPageItems.map((item) => _buildListItem(item)),
                // Fill remaining space if less than 5 items
                if (_currentPageItems.length < 5)
                  Expanded(child: Container()),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                isMobile ? _mobilePaginationText : _paginationText,
                style: theme.textTheme.muted.copyWith(
                  fontSize: 14,
                  color: colors.mutedForeground,
                ),
              ),
              const Spacer(),
              ShadButton.outline(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _canGoPrevious ? _previousPage : null,
                foregroundColor: colors.foreground,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              ShadButton.outline(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _canGoNext ? _nextPage : null,
                foregroundColor: colors.foreground,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(MSimpleListItem item) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    
    return _HoverableListItem(
      onTap: () => widget.onItemClick(item),
      child: Row(
        children: [
          ShadImage(
            item.icon,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 12,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          
          ShadPopover(
            controller: _popoverControllers[item.id]!,
            popover: (context) => SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadButton.ghost(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onItemDeleted(item.id);
                      _popoverControllers[item.id]?.toggle();
                    },
                    iconSize: const Size(16, 16),
                    icon: const ShadImage(LucideIcons.trash),
                    foregroundColor: theme.colorScheme.destructive,
                    child: Text(
                      'Delete',
                      style: theme.textTheme.p.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: IconButton(
              iconSize: 16,
              icon: const ShadImage(
                LucideIcons.ellipsis,
                width: 16,
                height: 16,
                alignment: Alignment.center,
              ),
              onPressed: () => _popoverControllers[item.id]?.toggle(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableListItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverableListItem({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverableListItem> createState() => _HoverableListItemState();
}

class _HoverableListItemState extends State<_HoverableListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? colors.secondary : colors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.child,
        ),
      ),
    );
  }
} 