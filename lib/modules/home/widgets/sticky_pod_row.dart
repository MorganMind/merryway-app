import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../family/models/pod_model.dart';

/// Sticky horizontally scrollable pod chips row
/// One selected (filled), others outlined
class StickyPodRow extends StatelessWidget {
  final List<Pod> pods;
  final String? selectedPodId;
  final bool isAllMode;
  final Function(String? podId, bool isAll) onPodSelected;
  final VoidCallback onManagePods;

  const StickyPodRow({
    Key? key,
    required this.pods,
    this.selectedPodId,
    required this.isAllMode,
    required this.onPodSelected,
    required this.onManagePods,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, // Match greeting section padding
        vertical: RedesignTokens.space12,
      ),
      decoration: BoxDecoration(
        color: RedesignTokens.cardSurfaceWithOpacity,
        border: Border(
          bottom: BorderSide(
            color: RedesignTokens.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" mode chip
                  _buildPodChip(
                    context,
                    label: 'All',
                    emoji: '🌟',
                    isSelected: isAllMode,
                    onTap: () => onPodSelected(null, true),
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                  
                  // Pod chips
                  ...pods.map((pod) {
                    final isSelected = !isAllMode && pod.id == selectedPodId;
                    return Padding(
                      padding: const EdgeInsets.only(right: RedesignTokens.space8),
                      child: _buildPodChip(
                        context,
                        label: pod.name,
                        emoji: pod.icon,
                        isSelected: isSelected,
                        onTap: () => onPodSelected(pod.id, false),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: RedesignTokens.space12),
          
          // Manage button
          InkWell(
            onTap: onManagePods,
            borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RedesignTokens.space12,
                vertical: RedesignTokens.space8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: RedesignTokens.accentGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Manage',
                    style: RedesignTokens.meta.copyWith(
                      color: RedesignTokens.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodChip(
    BuildContext context, {
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space16,
          vertical: RedesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? RedesignTokens.accentGold : Colors.transparent,
          border: Border.all(
            color: isSelected ? RedesignTokens.accentGold : RedesignTokens.divider,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : RedesignTokens.slate,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: RedesignTokens.meta.copyWith(
                color: isSelected ? Colors.white : RedesignTokens.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

