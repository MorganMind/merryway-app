import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';

/// Displays a constraint chip
class ConstraintChip extends StatelessWidget {
  final PlanConstraint constraint;
  final VoidCallback? onRemove;

  const ConstraintChip({
    super.key,
    required this.constraint,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _getConstraintDisplay();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RedesignTokens.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RedesignTokens.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: RedesignTokens.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: RedesignTokens.ink,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16,
                color: RedesignTokens.slate,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (IconData, String) _getConstraintDisplay() {
    final type = constraint.type ?? 'unknown';
    final valueJson = constraint.valueJson ?? {};
    
    switch (type) {
      case 'cost_cap':
        final maxCost = valueJson['max_cost'] ?? 100;
        return (Icons.attach_money, 'Budget: \$$maxCost');
      
      case 'indoor_only':
        return (Icons.home, 'Indoor only');
      
      case 'outdoor_only':
        return (Icons.park, 'Outdoor only');
      
      case 'duration_cap':
        final maxDuration = valueJson['max_duration_min'] ?? 120;
        return (Icons.schedule, 'Max ${maxDuration}min');
      
      case 'time_window':
        final start = valueJson['start_time'] ?? 'Unknown';
        final end = valueJson['end_time'] ?? 'Unknown';
        return (Icons.access_time, '$start - $end');
      
      case 'location_radius':
        final radius = valueJson['radius_miles'] ?? 5;
        return (Icons.location_on, 'Within ${radius}mi');
      
      case 'age_appropriate':
        final minAge = valueJson['min_age'] ?? 0;
        final maxAge = valueJson['max_age'];
        if (maxAge != null) {
          return (Icons.child_care, 'Ages $minAge-$maxAge');
        } else {
          return (Icons.child_care, 'Ages $minAge+');
        }
      
      default:
        return (Icons.rule, type);
    }
  }
}

