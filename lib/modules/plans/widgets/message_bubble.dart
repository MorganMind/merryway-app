import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';
import 'morgan_badge.dart';

/// Chat message bubble
class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _hovering = false;
  static const _thinkingDots = ['.', '..', '...'];
  int _dotIndex = 0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((_) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % _thinkingDots.length;
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMorgan = message.authorType == 'morgan';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar aligned with top of chat bubble (not header)
          Padding(
            padding: const EdgeInsets.only(top: 20), // approximate header height
            child: _buildAvatar(isMorgan),
          ),
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
                    else if (widget.memberName != null)
                      Text(
                        widget.memberName!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      message.timeAgo ?? timeago.format(message.createdAt ?? DateTime.now()),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: RedesignTokens.slate.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Message body with hover copy button
                MouseRegion(
                  onEnter: (_) => setState(() => _hovering = true),
                  onExit: (_) => setState(() => _hovering = false),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMorgan
                              ? Colors.white
                              : (_hovering ? Colors.white : RedesignTokens.primary.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              selectionColor: RedesignTokens.accentGold,
                              cursorColor: RedesignTokens.ink,
                              selectionHandleColor: RedesignTokens.accentGold,
                            ),
                          ),
                          child: MarkdownBody(
                            data: message.bodyMd ?? 'No message content',
                            styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: RedesignTokens.ink,
                        height: 1.4,
                      ),
                      strong: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                      code: GoogleFonts.spaceMono(
                        fontSize: 14,
                        backgroundColor: Colors.grey.shade200,
                        color: RedesignTokens.ink,
                      ),
                      listBullet: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: Colors.blue.shade600,
                      ),
                      h1: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: RedesignTokens.ink,
                      ),
                      h2: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.ink,
                      ),
                      h3: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.ink,
                      ),
                            ),
                          ),
                        ),
                      ),
                      if (_hovering)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final text = message.bodyMd ?? '';
                                  await Clipboard.setData(ClipboardData(text: text));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied to clipboard')),
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.copy, size: 16, color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
      width: 43, // 20% larger than 36
      height: 43, // 20% larger than 36
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Very rounded squares
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
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/img/morgan-avatar.png',
                width: 43,
                height: 43,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            )
          : widget.memberPhotoUrl != null && widget.memberPhotoUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.memberPhotoUrl!,
                    width: 43,
                    height: 43,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitials(),
                  ),
                )
              : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = widget.memberName != null && widget.memberName!.isNotEmpty
        ? widget.memberName!
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
          fontSize: 17, // Larger font for bigger avatar
          fontWeight: FontWeight.w600,
          color: RedesignTokens.primary,
        ),
      ),
    );
  }
}

