import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class MSelect<T> extends StatelessWidget {
  final String placeholder;
  final List<Widget> options;
  final T? initialValue;
  final void Function(T?)? onChanged;
  final Widget Function(BuildContext, T) selectedOptionBuilder;
  final Object? icon;
  final bool boxShadow;
  final bool border;

  const MSelect({
    super.key,
    required this.placeholder,
    required this.options,
    this.initialValue,
    required this.onChanged,
    required this.selectedOptionBuilder,
    this.icon,
    this.boxShadow = true,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    
    return Container(
      height: 36,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: border ? Border.all(color: colors.border) : null,
        boxShadow: boxShadow ? [
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
        ] : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        child: Row(
          children: [
            if (icon != null) ...[
              ShadImage(
                icon!,
                width: 16,
                height: 16,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ShadSelect<T>(
                initialValue: initialValue,
                padding: const EdgeInsets.all(0),
                optionsPadding: const EdgeInsets.all(0),
                decoration: const ShadDecoration(
                  border: ShadBorder.none,
                  errorBorder: ShadBorder.none,
                  focusedBorder: ShadBorder.none,
                  secondaryBorder: ShadBorder.none,
                  secondaryFocusedBorder: ShadBorder.none,
                  secondaryErrorBorder: ShadBorder.none,
                ),
                placeholder: Text(
                  placeholder,
                  style: TextStyle(color: colors.mutedForeground),
                ),
                onChanged: onChanged,
                options: options,
                selectedOptionBuilder: selectedOptionBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 