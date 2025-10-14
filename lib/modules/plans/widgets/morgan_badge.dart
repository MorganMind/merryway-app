import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';

/// Small badge indicating Morgan (AI assistant)
class MorganBadge extends StatelessWidget {
  final double size;

  const MorganBadge({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.4,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RedesignTokens.accentGold,
            RedesignTokens.sparkle,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: size * 0.7,
            color: Colors.white,
          ),
          SizedBox(width: size * 0.2),
          Text(
            'Morgan',
            style: GoogleFonts.spaceGrotesk(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

