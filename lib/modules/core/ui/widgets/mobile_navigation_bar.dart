import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/settings/blocs/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MobileNavigationBar extends StatelessWidget {
  final UserData userData;

  const MobileNavigationBar({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final currentPath = GoRouterState.of(context).uri.path;
    final settingsBloc = sl<SettingsBloc>();

    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: LucideIcons.house,
            isSelected: currentPath.startsWith('/feed'),
            onTap: () => context.go('/feed'),
          ),
          // _NavBarItem(
          //   icon: LucideIcons.users,
          //   isSelected: currentPath.startsWith('/agent/'),
          //   onTap: () => context.go('/agent/${settingsBloc.state.settings?.lastAgentIds[
          //     settingsBloc.state.settings?.lastOrganizationId
          //   ]}'),
          // ),
          _NavBarItem(
            icon: LucideIcons.compass,
            isSelected: currentPath.startsWith('/explore'),
            onTap: () {}, // TODO: Implement routing
          ),
          _NavBarItem(
            icon: LucideIcons.idCard,
            isSelected: currentPath.startsWith('/agents'),
            onTap: () => context.go('/agents'),
          ),
          _NavBarItem(
            icon: LucideIcons.library,
            isSelected: currentPath.startsWith('/library'),
            onTap: () => context.go('/library'),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final Object icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            if (isSelected)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 4,
                  width: 60,
                  margin: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 40 : 30,
                height: isSelected ? 40 : 30,
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.4,
                  child: ShadImage(
                    icon,
                    width: isSelected ? 40 : 30,
                    height: isSelected ? 40 : 30,
                    color: isSelected ? colors.primary : colors.foreground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 