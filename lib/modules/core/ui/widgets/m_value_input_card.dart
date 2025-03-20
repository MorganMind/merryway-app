import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

// Data class for chips
class ValueChip {
  final String id;
  final String label;
  final Function(String id, String label) onRemove;

  ValueChip({
    required this.id,
    required this.label,
    required this.onRemove,
  });
}

class MValueInputCard extends StatefulWidget {
  final String title;
  final String description;
  final double? width;
  final List<ValueChip> values;
  final Future<List<String>> Function() onGenerateMore;
  final Function(String value) onSuggestionSelected;
  final Function(List<String>) onValuesSubmitted;

  const MValueInputCard({
    super.key,
    required this.title,
    required this.description,
    this.width,
    required this.values,
    required this.onGenerateMore,
    required this.onSuggestionSelected,
    required this.onValuesSubmitted,
  });

  @override
  State<MValueInputCard> createState() => _MValueInputCardState();
}

class _MValueInputCardState extends State<MValueInputCard> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _isGenerating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateMoreSuggestions() async {
    if (_isGenerating) return;
    
    setState(() => _isGenerating = true);
    try {
      _suggestions = await widget.onGenerateMore();
      setState(() {});
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _handleValueSubmit() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final values = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    widget.onValuesSubmitted(values);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return ShadCard(
      width: widget.width,
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

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.values.map((value) => _buildChip(value)).toList(),
          ),

          const SizedBox(height: 8),
          Divider(color: colors.border),
          const SizedBox(height: 6),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: ShadButton.outline(
                    height: 24,
                    padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                    foregroundColor: colors.mutedForeground,
                    decoration: ShadDecoration(
                      border: ShadBorder(
                        radius: BorderRadius.circular(9999),
                      )
                    ),
                    onPressed: () => widget.onSuggestionSelected(suggestion),
                    child: Text(suggestion, style: TextStyle(color: Color(0xFFA1A1AA))),
                  ),
                )),
                ShadButton.outline(
                  height: 24,
                  padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                  foregroundColor: colors.mutedForeground,
                  decoration: ShadDecoration(
                    border: ShadBorder(
                      radius: BorderRadius.circular(9999),
                    )
                  ),
                  onPressed: _generateMoreSuggestions,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isGenerating)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.mutedForeground,
                          ),
                        )
                      else
                        Icon(
                          LucideIcons.plus,
                          size: 16,
                          color: colors.mutedForeground,
                        ),
                      const SizedBox(width: 8),
                      const Text('Generate more', style: TextStyle(color: Color(0xFFA1A1AA))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          ShadInput(
            controller: _controller,
            placeholder: Text(
              'Enter values separated by comma (humorous, concise, etc)',
              style: TextStyle(color: colors.mutedForeground),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            style: TextStyle(color: colors.foreground),
            suffix: IconButton(
              icon: Icon(
                LucideIcons.arrowRight,
                color: colors.mutedForeground,
              ),
              onPressed: _handleValueSubmit,
            ),
            onSubmitted: (_) => _handleValueSubmit(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(ValueChip value) {
    return _HoverChip(
      label: value.label,
      onRemove: () => value.onRemove(value.id, value.label),
    );
  }
}

class _HoverChip extends StatefulWidget {
  final String label;
  final VoidCallback onRemove;

  const _HoverChip({
    required this.label,
    required this.onRemove,
  });

  @override
  State<_HoverChip> createState() => _HoverChipState();
}

class _HoverChipState extends State<_HoverChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovered ? colors.background : colors.secondary,
          border: Border.all(
            color: _isHovered ? colors.foreground : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                color: colors.foreground,
              ),
            ),
            const SizedBox(width: 4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  _isHovered ? LucideIcons.circleX : LucideIcons.x,
                  size: 14,
                  color: _isHovered ? colors.foreground : colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 