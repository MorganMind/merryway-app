import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';

/// Reusable sparkle loading animation widget
class SparkleLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final String? text;
  
  const SparkleLoading({
    super.key,
    this.size = 20.0,
    this.color,
    this.text,
  });

  @override
  State<SparkleLoading> createState() => _SparkleLoadingState();
}

class _SparkleLoadingState extends State<SparkleLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? RedesignTokens.accentGold;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final op1 = (0.3 + (t)).clamp(0.3, 1.0);
        final op2 = (0.3 + ((t + 0.33) % 1.0)).clamp(0.3, 1.0);
        final op3 = (0.3 + ((t + 0.66) % 1.0)).clamp(0.3, 1.0);
        
        if (widget.text != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSparkleDots(color),
              const SizedBox(width: 8),
              Text(
                widget.text!,
                style: const TextStyle(
                  color: RedesignTokens.slate,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }
        
        return _buildSparkleDots(color);
      },
    );
  }
  
  Widget _buildSparkleDots(Color color) {
    final t = _controller.value;
    final op1 = (0.3 + (t)).clamp(0.3, 1.0);
    final op2 = (0.3 + ((t + 0.33) % 1.0)).clamp(0.3, 1.0);
    final op3 = (0.3 + ((t + 0.66) % 1.0)).clamp(0.3, 1.0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: op1, 
          child: Icon(
            Icons.auto_awesome, 
            size: widget.size * 0.7, 
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Opacity(
          opacity: op2, 
          child: Icon(
            Icons.auto_awesome, 
            size: widget.size * 0.7, 
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Opacity(
          opacity: op3, 
          child: Icon(
            Icons.auto_awesome, 
            size: widget.size * 0.7, 
            color: color,
          ),
        ),
      ],
    );
  }
}
