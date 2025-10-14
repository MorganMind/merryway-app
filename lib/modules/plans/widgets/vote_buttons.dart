import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';

/// Vote buttons for proposals (+1, 0, -1)
class VoteButtons extends StatelessWidget {
  final int? currentVote;
  final Function(int) onVote;

  const VoteButtons({
    super.key,
    required this.currentVote,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVoteButton(
          value: 1,
          icon: Icons.thumb_up,
          label: 'Yes',
          color: RedesignTokens.accentGold,
        ),
        const SizedBox(width: 8),
        _buildVoteButton(
          value: 0,
          icon: Icons.remove_circle_outline,
          label: 'Maybe',
          color: RedesignTokens.slate,
        ),
        const SizedBox(width: 8),
        _buildVoteButton(
          value: -1,
          icon: Icons.thumb_down,
          label: 'No',
          color: Colors.red[400]!,
        ),
      ],
    );
  }

  Widget _buildVoteButton({
    required int value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = currentVote == value;

    return GestureDetector(
      onTap: () => onVote(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : RedesignTokens.slate.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : RedesignTokens.slate,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : RedesignTokens.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

