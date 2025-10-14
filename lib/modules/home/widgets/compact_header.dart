import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';

/// Compact sticky header bar with logo on left, navigation and menu on right
class CompactHeader extends StatelessWidget {
  final VoidCallback onIdeas;
  final VoidCallback onPlanner;
  final VoidCallback onTime;
  final VoidCallback onMoments;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onLogout;
  final Widget? userSwitcher;
  final bool isIdeasActive;
  final bool isPlannerActive;
  final bool isMomentsActive;

  const CompactHeader({
    Key? key,
    required this.onIdeas,
    required this.onPlanner,
    required this.onTime,
    required this.onMoments,
    required this.onSettings,
    required this.onHelp,
    required this.onLogout,
    this.userSwitcher,
    this.isIdeasActive = false,
    this.isPlannerActive = false,
    this.isMomentsActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: RedesignTokens.getGutter(MediaQuery.of(context).size.width),
        vertical: RedesignTokens.space12,
      ),
      decoration: BoxDecoration(
        color: RedesignTokens.cardSurfaceWithOpacity,
        boxShadow: RedesignTokens.shadowLevel2,
      ),
      child: Row(
        children: [
          // Left: Logo (15% larger)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Merryway',
                  style: GoogleFonts.eczar(
                    fontSize: 23, // 20 * 1.15 = 23
                    fontWeight: FontWeight.w800,
                    color: RedesignTokens.ink,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.auto_awesome,
                  color: RedesignTokens.sparkle,
                  size: 16, // 14 * 1.15 ≈ 16
                ),
              ],
            ),
          ),
          
          // Right: Navigation + User Switcher + Hamburger Menu
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Explore (Home) Navigation
              _NavButton(
                icon: Icons.lightbulb_outline,
                label: 'Explore',
                isActive: isIdeasActive,
                onPressed: onIdeas,
              ),
              
              const SizedBox(width: RedesignTokens.space4),
              
              // Moments Navigation
              _NavButton(
                icon: Icons.auto_awesome_outlined,
                label: 'Days',
                isActive: isMomentsActive,
                onPressed: onMoments,
              ),
              
              const SizedBox(width: RedesignTokens.space4),
              
              // Plans Navigation
              _NavButton(
                icon: Icons.menu_book,
                label: 'Plans',
                isActive: isPlannerActive,
                onPressed: onPlanner,
              ),
              
              const SizedBox(width: RedesignTokens.space4),
              
              // Trails (Health Dashboard) Navigation
              _NavButton(
                icon: Icons.explore_outlined,
                label: 'Trails',
                isActive: false,
                onPressed: onTime,
              ),
              
              // User Switcher (if provided)
              if (userSwitcher != null) ...[
                const SizedBox(width: RedesignTokens.space12),
                userSwitcher!,
              ],
              
              const SizedBox(width: RedesignTokens.space8),
              
              // Hamburger Menu (2 lines)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      onSettings();
                      break;
                    case 'help':
                      onHelp();
                      break;
                    case 'logout':
                      onLogout();
                      break;
                  }
                },
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        color: RedesignTokens.slate,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        color: RedesignTokens.slate,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 18, color: RedesignTokens.slate),
                        const SizedBox(width: RedesignTokens.space12),
                        Text('Settings', style: RedesignTokens.body),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, size: 18, color: RedesignTokens.slate),
                        const SizedBox(width: RedesignTokens.space12),
                        Text('Help', style: RedesignTokens.body),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: RedesignTokens.dangerColor),
                        const SizedBox(width: RedesignTokens.space12),
                        Text('Logout', style: RedesignTokens.body.copyWith(color: RedesignTokens.dangerColor)),
                      ],
                    ),
                  ),
                ],
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple navigation button with icon and label
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space12,
          vertical: RedesignTokens.space8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: isActive ? RedesignTokens.primaryPressed : RedesignTokens.slate,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: RedesignTokens.caption.copyWith(
                color: isActive ? RedesignTokens.primaryPressed : RedesignTokens.slate,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

