import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/services/lexorank.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

// Data model for list items
class MContextItem {
  final String id;
  final String content;
  final String priority;

  MContextItem({
    required this.id,
    required this.content,
    required this.priority,
  });
}

class MPriorityContextListCard extends StatefulWidget {
  final String title;
  final String description;
  final String headerText;
  final List<MContextItem> items;
  final Function(String content) onItemAdded;
  final Function(String id, String newPriority) onPriorityChanged;
  final Function(String id) onItemDeleted;
  final String placeholderText;

  const MPriorityContextListCard({
    super.key,
    required this.title,
    required this.description,
    required this.headerText,
    required this.items,
    required this.onItemAdded,
    required this.onPriorityChanged,
    required this.onItemDeleted,
    this.placeholderText = 'Enter context item...',
  });

  @override
  State<MPriorityContextListCard> createState() => _MPriorityContextListCardState();
}

class _MPriorityContextListCardState extends State<MPriorityContextListCard> {
  final TextEditingController _controller = TextEditingController();
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
  void didUpdateWidget(MPriorityContextListCard oldWidget) {
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
    _controller.dispose();
    // Dispose all popover controllers
    for (var controller in _popoverControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleItemSubmit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    widget.onItemAdded(content);
    _controller.clear();
  }

  List<MContextItem> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.items.length);
    return widget.items.sublist(startIndex, endIndex);
  }

  String get _paginationText {
    final startIndex = (_currentPage * _itemsPerPage) + 1;
    final endIndex = (((_currentPage + 1) * _itemsPerPage))
        .clamp(0, widget.items.length);
    return '$startIndex-$endIndex of ${widget.items.length} ${widget.headerText.toLowerCase()}';
  }

  String get _mobilePaginationText {
    final startIndex = (_currentPage * _itemsPerPage) + 1;
    final endIndex = (((_currentPage + 1) * _itemsPerPage))
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

  // Add this method to handle showing the priority management view
  void _showPriorityManagement() {
    final isMobile = MediaQuery.of(context).size.width < 640;
    
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.zero,
          ),
        ),
        builder: (context) => _PriorityManagementView(
          items: widget.items,
          headerText: widget.headerText,
          onPriorityChanged: widget.onPriorityChanged,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog.fullscreen(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 675),
                child: _PriorityManagementView(
                  items: widget.items,
                  headerText: widget.headerText,
                  onPriorityChanged: widget.onPriorityChanged,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

    return ShadCard(
      padding: isMobile 
            ? const EdgeInsets.all(16)
            : const EdgeInsets.all(24),
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

          ShadInput(
            controller: _controller,
            placeholder: Text(
              widget.placeholderText,
              style: TextStyle(color: colors.mutedForeground),
            ),
            style: TextStyle(color: colors.foreground),
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            suffix: IconButton(
              icon: Icon(
                LucideIcons.arrowRight,
                color: colors.mutedForeground,
              ),
              onPressed: _handleItemSubmit,
            ),
            onSubmitted: (_) => _handleItemSubmit(),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.border),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.headerText,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),

                Container(
                  height: !isMobile 
                            ? 5 * 73  // Each item is 64px (16px padding top/bottom + 32px content height)
                            : 5 * 64,
                  child: Column(
                    children: [
                      ..._currentPageItems.map((item) => _buildListItem(item)),
                      // Fill remaining space if less than 5 items
                      if (_currentPageItems.length < 5)
                        Expanded(child: Container()),
                    ],
                  ),
                ),
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

  Widget _buildListItem(MContextItem item) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    
    return Container(
      padding: sl<LayoutBloc>().state.layoutType != LayoutType.mobile 
            ? const EdgeInsets.all(16)
            : const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: colors.foreground,
              ),
            ),
          ),
          
          IconButton(
            icon: Icon(
              LucideIcons.moveVertical,
              size: 16,
              color: colors.mutedForeground,
            ),
            onPressed: _showPriorityManagement,
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

class _PriorityManagementView extends StatefulWidget {
  final List<MContextItem> items;
  final String headerText;
  final Function(String id, String newPriority) onPriorityChanged;

  const _PriorityManagementView({
    required this.items,
    required this.headerText,
    required this.onPriorityChanged,
  });

  @override
  State<_PriorityManagementView> createState() => _PriorityManagementViewState();
}

class _PriorityManagementViewState extends State<_PriorityManagementView> {
  late List<MContextItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(_PriorityManagementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.items, oldWidget.items)) {
      _items = List.from(widget.items);
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);

      // Get surrounding items for priority calculation
      String? beforePriority;
      String? afterPriority;

      if (newIndex == 0) {
        // Moving to the very top - use null as beforePriority to indicate highest priority
        beforePriority = null;
        afterPriority = _items.length > 1 ? _items[1].priority : null;
      } else if (newIndex == _items.length - 1) {
        // Moving to the very bottom - use null as afterPriority to indicate lowest priority
        beforePriority = _items[newIndex - 1].priority;
        afterPriority = null;
      } else {
        // Moving somewhere in the middle
        beforePriority = _items[newIndex - 1].priority;
        afterPriority = _items[newIndex + 1].priority;
      }
      
      final newRank = LexoRank.between(beforePriority, afterPriority);
      widget.onPriorityChanged(item.id, newRank);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.fromLTRB(24, 24, 24, 0),
          decoration: BoxDecoration(
            color: colors.background,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage ${widget.headerText}',
                      style: theme.textTheme.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag to reorder ${widget.headerText.toLowerCase()}',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 14,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.x,
                  color: colors.mutedForeground,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        // List container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorder: _handleReorder,
              children: _items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildDraggableItem(item, index);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableItem(MContextItem item, int index) {
    final colors = context.appTheme;
    
    return Container(
      key: ValueKey(item.id),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              LucideIcons.gripVertical,
              size: 16,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 