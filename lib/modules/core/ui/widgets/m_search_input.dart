import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class MSearchInput extends StatelessWidget {
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const MSearchInput({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: colors.foreground.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: placeholder ?? 'Search...',
          hintStyle: theme.textTheme.muted,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              LucideIcons.search,
              size: 20,
              color: colors.mutedForeground,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
        style: theme.textTheme.p.copyWith(
          color: colors.foreground,
        ),
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
} 