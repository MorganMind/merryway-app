import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';

/// A gentle, Mary Poppins-inspired loading indicator
/// Features a soft pulsing sparkle with floating elements
class GentleLoadingIndicator extends StatefulWidget {
  final String? message;
  
  const GentleLoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  State<GentleLoadingIndicator> createState() => _GentleLoadingIndicatorState();
}

class _GentleLoadingIndicatorState extends State<GentleLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated sparkle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Soft glow background
                  Container(
                    width: 80 * _pulseAnimation.value,
                    height: 80 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          RedesignTokens.accentGold.withOpacity(0.15 * _opacityAnimation.value),
                          RedesignTokens.accentGold.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // Central sparkle
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: RedesignTokens.sparkle,
                      ),
                    ),
                  ),
                  // Floating sparkles
                  ..._buildFloatingSparkles(),
                ],
              );
            },
          ),
          
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: RedesignTokens.body.copyWith(
                color: RedesignTokens.slate,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFloatingSparkles() {
    return [
      // Top sparkle
      Positioned(
        top: 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = 10 * (0.5 - _controller.value).abs();
            return Transform.translate(
              offset: Offset(0, -offset),
              child: Opacity(
                opacity: 0.3 + (0.4 * _opacityAnimation.value),
                child: Icon(
                  Icons.star,
                  size: 12,
                  color: RedesignTokens.accentGold,
                ),
              ),
            );
          },
        ),
      ),
      // Bottom-left sparkle
      Positioned(
        bottom: 5,
        left: 5,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = 8 * (0.5 - (_controller.value + 0.3) % 1.0).abs();
            return Transform.translate(
              offset: Offset(-offset * 0.7, offset),
              child: Opacity(
                opacity: 0.25 + (0.35 * _opacityAnimation.value),
                child: Icon(
                  Icons.star,
                  size: 10,
                  color: RedesignTokens.accentSage,
                ),
              ),
            );
          },
        ),
      ),
      // Bottom-right sparkle
      Positioned(
        bottom: 5,
        right: 5,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = 8 * (0.5 - (_controller.value + 0.6) % 1.0).abs();
            return Transform.translate(
              offset: Offset(offset * 0.7, offset),
              child: Opacity(
                opacity: 0.25 + (0.35 * _opacityAnimation.value),
                child: Icon(
                  Icons.star,
                  size: 10,
                  color: RedesignTokens.sparkle,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

