import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Wrapper that fades out a widget when it approaches the bottom of the viewport
/// Used to fade cards when they go under the bottom composer
class FadeOnScrollWrapper extends StatefulWidget {
  final Widget child;
  final double bottomReservedHeight; // Height of bottom composer
  final double fadeStartOffset; // Start fading this many pixels before the bottom

  const FadeOnScrollWrapper({
    Key? key,
    required this.child,
    this.bottomReservedHeight = 120,
    this.fadeStartOffset = 100,
  }) : super(key: key);

  @override
  State<FadeOnScrollWrapper> createState() => _FadeOnScrollWrapperState();
}

class _FadeOnScrollWrapperState extends State<FadeOnScrollWrapper> {
  final GlobalKey _key = GlobalKey();
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOpacity();
    });
  }

  void _updateOpacity() {
    if (!mounted) return;

    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // If we can't measure yet, default to full opacity
      if (_opacity != 1.0) {
        setState(() {
          _opacity = 1.0;
        });
      }
      return;
    }

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Bottom of the card
    final cardBottom = position.dy + size.height;
    
    // Start fading when card bottom enters the fade zone
    final fadeZoneTop = screenHeight - widget.bottomReservedHeight - widget.fadeStartOffset;
    final fadeZoneBottom = screenHeight - widget.bottomReservedHeight;

    double newOpacity = 1.0;
    
    // Only fade if the card's bottom edge is in or past the fade zone
    if (cardBottom > fadeZoneTop && position.dy < screenHeight) {
      if (cardBottom >= fadeZoneBottom) {
        // Fully in the bottom zone - minimum opacity
        newOpacity = 0.1;
      } else {
        // In the fade zone - calculate opacity
        final fadeProgress = (cardBottom - fadeZoneTop) / (fadeZoneBottom - fadeZoneTop);
        newOpacity = 1.0 - (fadeProgress * 0.9); // Fade from 1.0 to 0.1
      }
    }

    if ((_opacity - newOpacity).abs() > 0.01) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Update on next frame to ensure proper measurements
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOpacity();
        });
        return false;
      },
      child: AnimatedOpacity(
        key: _key,
        opacity: _opacity,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}

