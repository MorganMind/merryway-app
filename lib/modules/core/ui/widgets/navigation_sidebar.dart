import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class NavigationSidebar extends StatefulWidget {

  const NavigationSidebar({
    super.key,
  });

  @override
  _NavigationSidebarState createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;
    final colors = context.appTheme;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          right: BorderSide(
            color: colors.muted,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            child: BlocBuilder<LayoutBloc, LayoutState>(
              builder: (context, state) {
                return Image.asset(
                  width: 150,
                  ShadTheme.of(context).brightness == Brightness.dark
                    ? 'assets/img/pb_logo_full_white.png'
                    : 'assets/img/pb_logo_full_black.png',
                  height: 25,
                );
              },
            ),
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.chartPie,
            label: 'Dashboard',
            route: '/dashboard',
            disabled: true,
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.cloudUpload,
            label: 'Content',
            route: '/content',
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.bookOpen,
            label: 'Knowledgebase',
            route: '/knowledgebase',
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.messageSquare,
            label: 'Conversations',
            route: '/conversations',
            disabled: true,
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.users,
            label: 'Members',
            route: '/members',
            disabled: true,
          ),
          _buildNavButton(
            context,
            icon: LucideIcons.dollarSign,
            label: 'Earnings',
            route: '/earnings',
            disabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    String? badge,
    bool disabled = false,
  }) {
    return _NavigationButton(
      icon: icon,
      label: label,
      route: route,
      badge: badge,
      disabled: disabled,
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;
  final bool disabled;

  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.disabled = false,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final isSelected = GoRouterState.of(context).uri.path == widget.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: InkWell(
          onTap: widget.disabled ? null : () => context.go(widget.route),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: (isSelected || (isHovered && !widget.disabled)) 
                  ? colors.foreground 
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.disabled
                      ? colors.foreground.withOpacity(0.4)
                      : (isSelected || (isHovered && !widget.disabled))
                          ? colors.background
                          : colors.foreground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.disabled
                          ? colors.foreground.withOpacity(0.4)
                          : (isSelected || (isHovered && !widget.disabled))
                              ? colors.background
                              : colors.foreground,
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.disabled
                          ? colors.foreground.withOpacity(0.1)
                          : (isSelected || (isHovered && !widget.disabled))
                              ? colors.background.withOpacity(0.2)
                              : colors.foreground.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.badge!,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.disabled
                            ? colors.foreground.withOpacity(0.4)
                            : (isSelected || (isHovered && !widget.disabled))
                                ? colors.background
                                : colors.foreground,
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