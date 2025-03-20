import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shadcn_ui/src/utils/debug_check.dart';

class BaseAvatar extends StatelessWidget {
  const BaseAvatar(
    this.src, {
    super.key,
    this.placeholder,
    this.size,
    this.shape,
    this.backgroundColor,
    this.package,
    this.fit,
  });

  final ShadImageSrc src;
  final Widget? placeholder;
  final Size? size;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final String? package;
  final BoxFit? fit;

  Size effectiveSize(ShadThemeData theme) {
    return size ?? theme.avatarTheme.size ?? const Size.square(40);
  }

  ShapeBorder effectiveShape(ShadThemeData theme) {
    return shape ?? theme.avatarTheme.shape ?? const CircleBorder();
  }

  Color? effectiveBackgroundColor(ShadThemeData theme) {
    return backgroundColor ??
        theme.avatarTheme.backgroundColor ??
        theme.colorScheme.muted;
  }

  BoxFit effectiveFit(ShadThemeData theme) {
    return fit ?? BoxFit.cover;
  }

  Widget frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    return frame == null ? placeholder ?? const SizedBox.shrink() : child;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasShadTheme(context));
    final theme = ShadTheme.of(context);
    final size = effectiveSize(theme);
    final fit = effectiveFit(theme);
    
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        width: size.width,
        height: size.height,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: effectiveShape(theme),
          color: effectiveBackgroundColor(theme),
        ),
        child: ShadImage(
          src, 
          placeholder: placeholder, 
          fit: fit,
          width: size.width,
          height: size.height,
        ),
      )
    );
  }
}
