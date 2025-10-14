import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/redesign_tokens.dart';

/// ChatGPT-style conversational composer at bottom of screen
/// Always visible, natural language first, with quick chips
class BottomComposer extends StatefulWidget {
  final Function(String query, Map<String, dynamic> tokens) onSubmit;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;
  final VoidCallback onMagic;
  final bool isRecording;
  final String currentWeather;
  final String currentTimeOfDay;
  final String currentDayOfWeek;
  final Function(String) onWeatherChanged;
  final Function(String) onTimeOfDayChanged;
  final Function(String) onDayOfWeekChanged;

  const BottomComposer({
    Key? key,
    required this.onSubmit,
    required this.onVoiceStart,
    required this.onVoiceStop,
    required this.onMagic,
    this.isRecording = false,
    required this.currentWeather,
    required this.currentTimeOfDay,
    required this.currentDayOfWeek,
    required this.onWeatherChanged,
    required this.onTimeOfDayChanged,
    required this.onDayOfWeekChanged,
  }) : super(key: key);

  @override
  State<BottomComposer> createState() => _BottomComposerState();
}

class _BottomComposerState extends State<BottomComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showQuickChips = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showQuickChips = _focusNode.hasFocus;
    });
  }

  void _handleSubmit() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      // Show suggestions
      setState(() {
        _showQuickChips = true;
      });
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Parse tokens from query
    final tokens = _parseTokens(query);
    
    widget.onSubmit(query, tokens);

    // Clear and reset
    _controller.clear();
    setState(() {
      _isSending = false;
      _showQuickChips = false;
    });
    _focusNode.unfocus();
  }

  Map<String, dynamic> _parseTokens(String query) {
    final tokens = <String, dynamic>{};
    
    // Simple token parsing (could be enhanced with NLU)
    final lowerQuery = query.toLowerCase();
    
    // Duration
    final durationMatch = RegExp(r'(\d+)\s*(?:min|minute)s?').firstMatch(lowerQuery);
    if (durationMatch != null) {
      tokens['duration_minutes'] = int.parse(durationMatch.group(1)!);
    }
    
    // Cost
    if (lowerQuery.contains('\$0') || lowerQuery.contains('free')) {
      tokens['cost_band'] = 'free';
    }
    
    // Location
    if (lowerQuery.contains('near') || lowerQuery.contains('home') || lowerQuery.contains('close')) {
      tokens['location_hint'] = 'near_home';
    }
    
    // Indoor/Outdoor
    if (lowerQuery.contains('indoor')) {
      tokens['venue_type'] = 'indoor';
    } else if (lowerQuery.contains('outdoor')) {
      tokens['venue_type'] = 'outdoor';
    }
    
    // Weather
    if (lowerQuery.contains('rainy') || lowerQuery.contains('rain')) {
      tokens['weather_hint'] = 'rainy';
    } else if (lowerQuery.contains('sunny') || lowerQuery.contains('sun')) {
      tokens['weather_hint'] = 'sunny';
    }
    
    return tokens;
  }

  void _insertQuickChip(String text) {
    final currentText = _controller.text;
    final newText = currentText.isEmpty ? text : '$currentText $text';
    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Context options row (collapsible)
        if (_showQuickChips)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: RedesignTokens.space16,
              vertical: RedesignTokens.space8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Suggestions button (moved from main input row)
                  _buildContextOption(
                    icon: Icons.auto_awesome,
                    onTap: widget.onMagic,
                    color: RedesignTokens.accentGold,
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  _buildContextOption(
                    icon: _getWeatherIcon(widget.currentWeather),
                    onTap: () {
                      final options = ['sunny', 'cloudy', 'rainy'];
                      final currentIndex = options.indexOf(widget.currentWeather);
                      final nextIndex = (currentIndex + 1) % options.length;
                      widget.onWeatherChanged(options[nextIndex]);
                    },
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  _buildContextOption(
                    icon: _getTimeIcon(widget.currentTimeOfDay),
                    onTap: () {
                      final options = ['morning', 'afternoon', 'evening'];
                      final currentIndex = options.indexOf(widget.currentTimeOfDay);
                      final nextIndex = (currentIndex + 1) % options.length;
                      widget.onTimeOfDayChanged(options[nextIndex]);
                    },
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  _buildContextOption(
                    label: _getDayAbbreviation(widget.currentDayOfWeek),
                    onTap: () {
                      final options = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
                      final currentIndex = options.indexOf(widget.currentDayOfWeek);
                      final nextIndex = (currentIndex + 1) % options.length;
                      widget.onDayOfWeekChanged(options[nextIndex]);
                    },
                  ),
                ],
              ),
            ),
          ),
        
        // Composer bar
        Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 720 : double.infinity,
          ),
          margin: EdgeInsets.fromLTRB(
            isDesktop ? RedesignTokens.space16 : 0,
            0,
            isDesktop ? RedesignTokens.space16 : 0,
            isDesktop ? MediaQuery.of(context).padding.bottom + RedesignTokens.space16 : 0,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'What are you thinking about doing?',
              hintStyle: RedesignTokens.body.copyWith(
                color: RedesignTokens.mutedText.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24), // More rounded corners
                borderSide: BorderSide(color: RedesignTokens.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: RedesignTokens.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: RedesignTokens.accentGold, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: RedesignTokens.space16,
                vertical: RedesignTokens.space12,
              ),
              suffixIcon: hasText 
                ? _buildAccessoryButton(
                    icon: _isSending ? Icons.hourglass_empty : Icons.send,
                    onPressed: _isSending ? null : _handleSubmit,
                    color: RedesignTokens.accentGold,
                    isInsideField: true,
                  )
                : _buildAccessoryButton(
                    icon: widget.isRecording ? Icons.stop : Icons.mic,
                    onPressed: widget.isRecording ? widget.onVoiceStop : widget.onVoiceStart,
                    color: widget.isRecording ? RedesignTokens.dangerColor : RedesignTokens.slate,
                    isInsideField: true,
                  ),
            ),
            style: RedesignTokens.body,
            onSubmitted: (_) => _handleSubmit(),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label) {
    return InkWell(
      onTap: () => _insertQuickChip(label),
      borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: RedesignTokens.infoPillBg,
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
          border: Border.all(color: RedesignTokens.divider),
        ),
        child: Text(
          label,
          style: RedesignTokens.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: RedesignTokens.slate,
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    bool isInsideField = false,
  }) {
    return IconButton(
      onPressed: onPressed != null ? () {
        // Prevent double-click by disabling the button temporarily
        if (_isSending) return;
        onPressed();
      } : null,
      icon: Icon(icon, size: 20),
      color: color,
      padding: isInsideField ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
      constraints: isInsideField 
        ? const BoxConstraints(minWidth: 32, minHeight: 32)
        : const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _buildContextOption({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? RedesignTokens.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: optionColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
          border: Border.all(color: optionColor.withOpacity(0.2)),
        ),
        child: icon != null
            ? Icon(icon, size: 18, color: optionColor)
            : Text(
                label ?? '',
                style: RedesignTokens.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: optionColor,
                ),
              ),
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.umbrella;
      default:
        return Icons.wb_sunny;
    }
  }

  IconData _getTimeIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return Icons.wb_twilight;
      case 'afternoon':
        return Icons.wb_sunny;
      case 'evening':
        return Icons.nights_stay;
      default:
        return Icons.wb_sunny;
    }
  }

  String _getDayAbbreviation(String day) {
    switch (day) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return 'Mon';
    }
  }
}

