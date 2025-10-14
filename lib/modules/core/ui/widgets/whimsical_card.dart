import 'package:flutter/material.dart';

/// Card wrapper that adds subtle hover effects (lift and scale)
/// for a more interactive, whimsical feel
class WhimsicalCard extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final double hoverElevation;
  final double hoverScale;

  const WhimsicalCard({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverElevation = 8.0,
    this.hoverScale = 1.01, // 1% scale increase
  }) : super(key: key);

  @override
  State<WhimsicalCard> createState() => _WhimsicalCardState();
}

class _WhimsicalCardState extends State<WhimsicalCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? widget.hoverScale : 1.0,
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          // Elevation is handled by the child card's shadow,
          // this container is just for the scale and potential future effects
          child: widget.child,
        ),
      ),
    );
  }
}

