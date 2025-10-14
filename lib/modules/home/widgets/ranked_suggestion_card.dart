import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';

class RankedSuggestionCard extends StatefulWidget {
  final ActivitySuggestion suggestion;
  final bool isPrimary;
  final int rank; // 1, 2, or 3
  final Function(String action, int? rating) onFeedback;
  final bool isLoading;

  const RankedSuggestionCard({
    super.key,
    required this.suggestion,
    this.isPrimary = false,
    required this.rank,
    required this.onFeedback,
    this.isLoading = false,
  });

  @override
  State<RankedSuggestionCard> createState() => _RankedSuggestionCardState();
}

class _RankedSuggestionCardState extends State<RankedSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: widget.isPrimary ? 4 : 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(),
                ),
                border: widget.isPrimary
                    ? Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with rank badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rank badge
                              if (widget.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '⭐ Top Pick',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Option ${widget.rank}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Activity title
                    Text(
                      widget.suggestion.activity,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Rationale
                    Text(
                      widget.suggestion.rationale,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Meta row (time + tags)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration
                        if (widget.suggestion.durationMinutes != null)
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.suggestion.durationMinutes} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        // Tags (compact)
                        if (widget.suggestion.tags.isNotEmpty)
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              alignment: WrapAlignment.end,
                              children: widget.suggestion.tags.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),

                    // Show feedback actions for primary card
                    if (widget.isPrimary) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 12),
                      _buildFeedbackActions(context),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.isLoading
                ? null
                : () => widget.onFeedback('skip', null),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Skip', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.isLoading
                ? null
                : () => widget.onFeedback('accept', null),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Try It!', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _getPrimaryColor(),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors() {
    if (widget.isPrimary) {
      // Primary gradient - vibrant
      return [
        const Color(0xFFB4D7E8),
        const Color(0xFF7FB3D5),
      ];
    }

    // Secondary gradients - softer
    const gradients = [
      [Color(0xFFF4A6B8), Color(0xFFE88FA0)], // Warm pink
      [Color(0xFFE5C17D), Color(0xFFD9A55D)], // Golden
    ];

    return gradients[(widget.rank - 2) % gradients.length];
  }

  Color _getPrimaryColor() {
    final colors = _getGradientColors();
    return colors.first;
  }
}

