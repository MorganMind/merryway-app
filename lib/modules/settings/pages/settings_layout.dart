import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_event.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsLayout extends StatefulWidget {
  final Widget child;

  const SettingsLayout({
    super.key,
    required this.child,
  });

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {  
  final layoutBloc = sl<LayoutBloc>();

  @override
  void initState() {
    super.initState();
    layoutBloc.add(SetSidebarVisibility(false));
    layoutBloc.add(SetHeaderVisibility(false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;
    final currentPath = GoRouterState.of(context).uri.path;

    return Dialog.fullscreen(
      child: Material(
        color: colors.background,
        child: Column(
          children: [
            // Desktop header
            if (!isMobile)
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.border),
                  ),
                ),
                child: Row(
                  children: [
                    // Header text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration',
                          style: theme.textTheme.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your account settings, preferences and Morgan Personnel',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 14,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Close button
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: ShadImage(
                        LucideIcons.x,
                        width: 20,
                        height: 20,
                        color: colors.mutedForeground,
                      ),
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
              ),

            // Mobile navigation tabs
            if (isMobile)
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [ 
                      _buildMobileTab(
                        label: 'About you',
                        route: '/settings/about-you',
                        isSelected: currentPath == '/settings/about-you' || currentPath == '/settings',
                        paddingLeft: 0,
                      ),
                      _buildMobileTab(
                        label: 'Preferences',
                        route: '/settings/preferences',
                        isSelected: currentPath == '/settings/preferences',
                      ),
                      _buildMobileTab(
                        label: 'Manage Groups',
                        route: '/settings/groups',
                        isSelected: currentPath == '/settings/groups',
                      ),
                      _buildMobileTab(
                        label: 'Notifications',
                        route: '/settings/notifications',
                        isSelected: currentPath == '/settings/notifications',
                      ),
                      _buildMobileTab(
                        label: 'Integrations',
                        route: '/settings/integrations',
                        isSelected: currentPath == '/settings/integrations',
                      ),
                      _buildMobileTab(
                        label: 'Billing',
                        route: '/settings/billing',
                        isSelected: currentPath == '/settings/billing',
                      ),
                      _buildMobileTab(
                        label: 'Security',
                        route: '/settings/security',
                        isSelected: currentPath == '/settings/security',
                      ),
                      _buildMobileTab(
                        label: 'Appearance',
                        route: '/settings/appearance',
                        isSelected: currentPath == '/settings/appearance',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

            // Content area with sidebar and main content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings navigation sidebar - hide on mobile
                  if (!isMobile)
                    Container(
                      width: 260,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: colors.border),
                        ),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          _buildNavItem(
                            icon: LucideIcons.user,
                            label: 'About you',
                            route: '/settings/about-you',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.settings2,
                            label: 'Preferences',
                            route: '/settings/preferences',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.users,
                            label: 'Manage Groups',
                            route: '/settings/groups',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.bell,
                            label: 'Notifications',
                            route: '/settings/notifications',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.plugZap,
                            label: 'Integrations',
                            route: '/settings/integrations',
                            badge: 'Coming Soon',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.creditCard,
                            label: 'Billing',
                            route: '/settings/billing',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.shield,
                            label: 'Security',
                            route: '/settings/security',
                          ),
                          _buildNavItem(
                            icon: LucideIcons.palette,
                            label: 'Appearance',
                            route: '/settings/appearance',
                          ),
                        ],
                      ),
                    ),

                  // Main content area
                  Expanded(
                    child: Container(
                      color: colors.background,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTab({
    required String label,
    required String route,
    required bool isSelected,
    double paddingLeft = 16,
    bool isLast = false,
  }) {
    final colors = context.appTheme;
    
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          height: 20,
          padding: const EdgeInsets.only(right: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              right: isLast ? BorderSide.none : BorderSide(
                color: colors.border,
                width: 1,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? colors.foreground : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: colors.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    String? badge,
  }) {
    final colors = context.appTheme;
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route || currentPath == '/settings' && route == '/settings/about-you';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? colors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(6),
          hoverColor: colors.secondary,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ShadImage(
                  icon,
                  width: 16,
                  height: 16,
                  color: colors.foreground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 