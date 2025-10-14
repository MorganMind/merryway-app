import 'package:flutter/material.dart';

class FeedbackActions extends StatefulWidget {
  final Function(String action, int? rating) onFeedback;
  final bool isLoading;

  const FeedbackActions({
    super.key,
    required this.onFeedback,
    this.isLoading = false,
  });

  @override
  State<FeedbackActions> createState() => _FeedbackActionsState();
}

class _FeedbackActionsState extends State<FeedbackActions> {
  int? selectedRating;
  bool showRating = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          widget.onFeedback('skip', selectedRating);
                          _reset();
                        },
                  icon: const Icon(Icons.close),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B8B8B),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          setState(() => showRating = !showRating);
                        },
                  icon: Icon(
                    showRating ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: const Text('Rate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B8B8B),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          widget.onFeedback('accept', selectedRating);
                          _reset();
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Try It'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4D7E8),
                  ),
                ),
              ),
            ],
          ),
          // Rating stars (expanded)
          if (showRating)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How did it go?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8B8B8B),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      int rating = index + 1;
                      bool isSelected = selectedRating == rating;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedRating = rating);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_outline,
                              color: const Color(0xFFE5C17D),
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  if (selectedRating != null)
                    ElevatedButton(
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              widget.onFeedback('complete', selectedRating);
                              _reset();
                            },
                      child: const Text('Mark Complete'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      selectedRating = null;
      showRating = false;
    });
  }
}

