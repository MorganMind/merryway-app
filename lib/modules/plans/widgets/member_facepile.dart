import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';

/// Displays a horizontal stack of member avatars
class MemberFacepile extends StatelessWidget {
  final List<MemberFacepileItem> members;
  final int maxVisible;
  final double size;

  const MemberFacepile({
    super.key,
    required this.members,
    this.maxVisible = 4,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final visibleMembers = members.take(maxVisible).toList();
    final overflow = members.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          
          return Transform.translate(
            offset: Offset(-index * (size * 0.3), 0),
            child: _buildAvatar(member),
          );
        }),
        if (overflow > 0)
          Transform.translate(
            offset: Offset(-visibleMembers.length * (size * 0.3), 0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: RedesignTokens.slate.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$overflow',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w600,
                    color: RedesignTokens.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(MemberFacepileItem member) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: RedesignTokens.primary.withOpacity(0.15),
      ),
      child: member.photoUrl != null && member.photoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                member.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitials(member.name),
              ),
            )
          : _buildInitials(member.name),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((word) => word[0]).join().toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: GoogleFonts.spaceGrotesk(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: RedesignTokens.primary,
        ),
      ),
    );
  }
}

