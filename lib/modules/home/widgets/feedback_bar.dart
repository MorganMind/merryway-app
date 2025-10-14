import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/redesign_tokens.dart';

/// Floating feedback bar with heart/neutral/hide controls
/// Lightweight signal per suggestion for learning
class FeedbackBar extends StatefulWidget {
  final Function(FeedbackAction) onAction;
  final bool alwaysVisible; // True on mobile, false on desktop (show on hover)

  const FeedbackBar({
    Key? key,
    required this.onAction,
    this.alwaysVisible = true,
  }) : super(key: key);

  @override
  State<FeedbackBar> createState() => _FeedbackBarState();
}

class _FeedbackBarState extends State<FeedbackBar> with SingleTickerProviderStateMixin {
  FeedbackAction? _selectedAction;
  late AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _handleAction(FeedbackAction action) {
    setState(() {
      _selectedAction = action;
    });

    if (action == FeedbackAction.like) {
      _burstController.forward(from: 0);
    }

    widget.onAction(action);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Positioned(
      bottom: RedesignTokens.space8,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: RedesignTokens.space8),
              decoration: BoxDecoration(
                color: RedesignTokens.feedbackBarBg(brightness),
                borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 8),
                    blurRadius: 24,
                    color: Color(0x1F000000), // rgba(0,0,0,0.12)
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFeedbackButton(
                    icon: Icons.favorite,
                    label: 'Like',
                    action: FeedbackAction.like,
                    activeColor: RedesignTokens.accentGold,
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  _buildFeedbackButton(
                    icon: Icons.circle,
                    label: 'Skip',
                    action: FeedbackAction.neutral,
                    activeColor: RedesignTokens.ink,
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  _buildFeedbackButton(
                    icon: Icons.close,
                    label: 'Hide',
                    action: FeedbackAction.hide,
                    activeColor: RedesignTokens.dangerColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
    required FeedbackAction action,
    required Color activeColor,
  }) {
    final isSelected = _selectedAction == action;
    final isLike = action == FeedbackAction.like;
    // Use primary color for like action instead of gold
    final displayColor = isLike ? RedesignTokens.primary : activeColor;
    
    return InkWell(
      onTap: () => _handleAction(action),
      borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space12,
          vertical: RedesignTokens.space8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Burst effect for like
                if (isLike && isSelected)
                  AnimatedBuilder(
                    animation: _burstController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (_burstController.value * 0.5),
                        child: Opacity(
                          opacity: 1 - _burstController.value,
                          child: const Text(
                            '✨',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                // Icon
                Icon(
                  isSelected && action == FeedbackAction.like
                      ? Icons.favorite
                      : icon,
                  size: 20,
                  color: isSelected
                      ? displayColor
                      : RedesignTokens.slate.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: RedesignTokens.caption.copyWith(
                fontSize: 10,
                color: isSelected
                    ? displayColor
                    : RedesignTokens.slate.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum FeedbackAction {
  like,    // Save to Wishbook + strong positive signal
  neutral, // Soft skip (no hide)
  hide,    // Hide this idea (explainable reason optional)
}

