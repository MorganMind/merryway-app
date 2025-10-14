import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';
import 'morgan_badge.dart';

/// Chat message bubble
class MessageBubble extends StatelessWidget {
  final PlanMessage message;
  final String? memberName;
  final String? memberPhotoUrl;

  const MessageBubble({
    super.key,
    required this.message,
    this.memberName,
    this.memberPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isMorgan = message.authorType == 'morgan';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(isMorgan),
          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author + timestamp
                Row(
                  children: [
                    if (isMorgan)
                      const MorganBadge(size: 16)
                    else if (memberName != null)
                      Text(
                        memberName!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(message.createdAt ?? DateTime.now()),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Message body
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMorgan
                        ? RedesignTokens.accentGold.withOpacity(0.1)
                        : RedesignTokens.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MarkdownBody(
                    data: message.bodyMd,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: RedesignTokens.ink,
                        height: 1.5,
                      ),
                      strong: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: RedesignTokens.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isMorgan) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isMorgan
            ? LinearGradient(
                colors: [
                  RedesignTokens.accentGold,
                  RedesignTokens.sparkle,
                ],
              )
            : null,
        color: isMorgan ? null : RedesignTokens.primary.withOpacity(0.15),
      ),
      child: isMorgan
          ? const Icon(
              Icons.auto_awesome,
              size: 20,
              color: Colors.white,
            )
          : memberPhotoUrl != null && memberPhotoUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    memberPhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitials(),
                  ),
                )
              : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = memberName != null && memberName!.isNotEmpty
        ? memberName!
            .split(' ')
            .take(2)
            .map((word) => word[0])
            .join()
            .toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: RedesignTokens.primary,
        ),
      ),
    );
  }
}

