import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OverlayButton {
  final Widget buttonWidget;
  final VoidCallback onPressed;
  final double topOffset;
  final double leftOffset;
  
  OverlayEntry? _overlayEntry;
  bool _isVisible = true;

  OverlayButton({
    required this.buttonWidget,
    required this.onPressed,
    required this.topOffset,
    required this.leftOffset,
  });

  void show(BuildContext context) {
    if (!_isVisible) return;
    
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + topOffset,
          left: leftOffset,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: onPressed,
              child: buttonWidget,
            ),
          ),
        );
      },
    );

    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay != null) {
      print('EAT DOG SHIT: 1');
      overlay.insert(_overlayEntry!);
    }
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void setVisibility(bool isVisible) {
    _isVisible = isVisible;
    if (!isVisible) {
      hide();
    }
  }

  void dispose() {
    hide();
  }
} 