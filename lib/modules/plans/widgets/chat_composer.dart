import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';

/// Chat input composer with action chips
class ChatComposer extends StatefulWidget {
  final Function(String) onSend;
  final List<String> quickActions;
  final Function(String)? onQuickAction;

  const ChatComposer({
    super.key,
    required this.onSend,
    this.quickActions = const [],
    this.onQuickAction,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      // Ensure no stray newline remains
      _controller.text = '';
      _controller.selection = const TextSelection.collapsed(offset: 0);
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick action chips
          if (widget.quickActions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.quickActions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => widget.onQuickAction?.call(action),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: RedesignTokens.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: RedesignTokens.accentGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: RedesignTokens.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                action,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: RedesignTokens.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Text input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: _keyboardFocusNode,
                    onKey: (event) {
                      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                        final keys = RawKeyboard.instance.keysPressed;
                        final hasCtrl = keys.contains(LogicalKeyboardKey.controlLeft) ||
                            keys.contains(LogicalKeyboardKey.controlRight) ||
                            keys.contains(LogicalKeyboardKey.metaLeft) ||
                            keys.contains(LogicalKeyboardKey.metaRight);
                        if (hasCtrl) {
                          final text = _controller.text;
                          final selection = _controller.selection;
                          final insertAt = selection.start >= 0 ? selection.start : text.length;
                          final newText = text.replaceRange(insertAt, insertAt, '\n');
                          _controller.text = newText;
                          _controller.selection = TextSelection.collapsed(offset: insertAt + 1);
                        } else {
                          // Prevent newline insertion by handling and clearing
                          _send();
                          return; // swallow key
                        }
                      }
                    },
                    child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.spaceGrotesk(
                        color: RedesignTokens.slate,
                      ),
                      filled: true,
                        fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _hasText
                              ? IconButton(
                                  onPressed: _send,
                                  icon: const Icon(Icons.arrow_upward),
                                  color: Colors.white,
                                  style: IconButton.styleFrom(
                                    backgroundColor: RedesignTokens.primary,
                                    minimumSize: const Size(40, 40),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    // Voice input placeholder - to be wired later
                                  },
                                  icon: const Icon(Icons.mic),
                                  color: Colors.white,
                                  style: IconButton.styleFrom(
                                    backgroundColor: RedesignTokens.primary,
                                    minimumSize: const Size(40, 40),
                                  ),
                                ),
                        ),
                    ),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      color: RedesignTokens.ink,
                    ),
                      onChanged: (val) {
                        final has = val.trim().isNotEmpty;
                        if (has != _hasText) setState(() => _hasText = has);
                      },
                      onSubmitted: (_) {
                        // Prevent TextField from inserting newline when sending
                        _send();
                        _focusNode.requestFocus();
                      },
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
}

