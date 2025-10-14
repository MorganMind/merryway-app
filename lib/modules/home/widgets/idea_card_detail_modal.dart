import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../family/models/family_models.dart';

/// Full-screen modal showing expanded idea details with large photos
class IdeaCardDetailModal extends StatelessWidget {
  final String title;
  final String rationale;
  final int? durationMinutes;
  final List<String> tags;
  final String? location;
  final double? distanceMiles;
  final String? venueType;
  final List<FamilyMember> participants;
  final String description;
  final VoidCallback onMakeExperience;
  final List<String>? initialParticipantIds; // Active participants from card

  const IdeaCardDetailModal({
    Key? key,
    required this.title,
    required this.rationale,
    this.durationMinutes,
    this.tags = const [],
    this.location,
    this.distanceMiles,
    this.venueType,
    this.participants = const [],
    required this.description,
    required this.onMakeExperience,
    this.initialParticipantIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock photos for demo
    final photos = [
      'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop',
    ];

    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: CustomScrollView(
        slivers: [
          // App bar with back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: RedesignTokens.primary,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  Image.network(
                    photos[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: RedesignTokens.primary,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.white54),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: RedesignTokens.getGutter(MediaQuery.of(context).size.width),
                vertical: RedesignTokens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Why now
                  Container(
                    padding: const EdgeInsets.all(RedesignTokens.space16),
                    decoration: BoxDecoration(
                      color: RedesignTokens.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                      border: Border.all(
                        color: RedesignTokens.accentGold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: RedesignTokens.accentGold,
                          size: 20,
                        ),
                        const SizedBox(width: RedesignTokens.space12),
                        Expanded(
                          child: Text(
                            rationale,
                            style: RedesignTokens.body.copyWith(
                              color: RedesignTokens.ink,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: RedesignTokens.space24),

                  // Quick info pills
                  Wrap(
                    spacing: RedesignTokens.space8,
                    runSpacing: RedesignTokens.space8,
                    children: [
                      if (distanceMiles != null)
                        _buildInfoPill('${distanceMiles!.toStringAsFixed(1)} mi', Icons.location_on_outlined),
                      if (durationMinutes != null)
                        _buildInfoPill('$durationMinutes min', Icons.schedule_outlined),
                      if (venueType != null)
                        _buildInfoPill(venueType!, Icons.home_outlined),
                      ...tags.take(3).map((tag) => _buildInfoPill(tag, null)),
                    ],
                  ),

                  if (location != null) ...[
                    const SizedBox(height: RedesignTokens.space16),
                    Row(
                      children: [
                        Icon(Icons.place, size: 18, color: RedesignTokens.slate),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location!,
                            style: RedesignTokens.body.copyWith(
                              color: RedesignTokens.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Open in maps
                          },
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Directions'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: RedesignTokens.space32),

                  // Photo gallery
                  Text(
                    'Photos',
                    style: RedesignTokens.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RedesignTokens.space12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < photos.length - 1 ? RedesignTokens.space12 : 0,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                            child: Image.network(
                              photos[index],
                              width: 280,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 280,
                                height: 200,
                                color: RedesignTokens.divider,
                                child: const Icon(Icons.image_not_supported, size: 48),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: RedesignTokens.space32),

                  // What to expect
                  Text(
                    'What to Expect',
                    style: RedesignTokens.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RedesignTokens.space12),
                  Text(
                    description,
                    style: RedesignTokens.body.copyWith(
                      color: RedesignTokens.slate,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: RedesignTokens.space24),

                  // Prep details
                  _buildDetailSection(
                    'What to Wear',
                    Icons.checkroom,
                    'Comfortable clothes, sunscreen, water bottle',
                  ),
                  const SizedBox(height: RedesignTokens.space16),
                  _buildDetailSection(
                    'Food & Drinks',
                    Icons.restaurant,
                    'Snacks and drinks available on-site. Picnic area available.',
                  ),
                  const SizedBox(height: RedesignTokens.space16),
                  _buildDetailSection(
                    'Parking & Access',
                    Icons.local_parking,
                    'Free parking available. Wheelchair accessible.',
                  ),

                  const SizedBox(height: RedesignTokens.space32),

                  // Participants
                  if (participants.isNotEmpty) ...[
                    Text(
                      'Perfect For',
                      style: RedesignTokens.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RedesignTokens.space12),
                    Wrap(
                      spacing: RedesignTokens.space8,
                      runSpacing: RedesignTokens.space8,
                      children: participants.map((member) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RedesignTokens.space12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: RedesignTokens.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
                            border: Border.all(
                              color: RedesignTokens.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: RedesignTokens.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    member.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                member.name,
                                style: RedesignTokens.meta.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: RedesignTokens.slate,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: RedesignTokens.space32),
                  ],

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onMakeExperience();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RedesignTokens.primary,
                        foregroundColor: RedesignTokens.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: RedesignTokens.space16,
                          horizontal: RedesignTokens.space24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(
                        'Make it an experience',
                        style: RedesignTokens.button.copyWith(
                          color: RedesignTokens.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: RedesignTokens.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RedesignTokens.space12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: RedesignTokens.infoPillBg,
        borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: RedesignTokens.slate),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: RedesignTokens.caption.copyWith(
              color: RedesignTokens.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RedesignTokens.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: RedesignTokens.primary),
        ),
        const SizedBox(width: RedesignTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: RedesignTokens.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: RedesignTokens.body.copyWith(
                  color: RedesignTokens.slate,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

