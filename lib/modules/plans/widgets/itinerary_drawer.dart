import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';

/// Side drawer for viewing/editing itinerary
class ItineraryDrawer extends StatelessWidget {
  final PlanItinerary? itinerary;
  final VoidCallback? onEdit;

  const ItineraryDrawer({
    super.key,
    this.itinerary,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: RedesignTokens.canvas,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: RedesignTokens.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Itinerary',
                        style: GoogleFonts.eczar(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: itinerary == null
                    ? _buildEmptyState()
                    : _buildItinerary(itinerary!),
              ),

              // Edit button
              if (onEdit != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: Text(
                        itinerary == null ? 'Create Itinerary' : 'Edit',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RedesignTokens.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route,
              size: 64,
              color: RedesignTokens.slate.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No itinerary yet',
              style: GoogleFonts.eczar(
                fontSize: 20,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a step-by-step plan\nfor your activity',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItinerary(PlanItinerary itinerary) {
    final items = itinerary.itemsJson as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            itinerary.title,
            style: GoogleFonts.eczar(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 20),

          // Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            
            return _buildItineraryItem(
              index + 1,
              item['title'] as String? ?? '',
              item['description'] as String?,
              item['duration_min'] as int?,
              isLast: index == items.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItineraryItem(
    int step,
    String title,
    String? description,
    int? durationMin, {
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: RedesignTokens.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: RedesignTokens.primary.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    ),
                    if (durationMin != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: RedesignTokens.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${durationMin}min',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RedesignTokens.accentGold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: RedesignTokens.slate,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

