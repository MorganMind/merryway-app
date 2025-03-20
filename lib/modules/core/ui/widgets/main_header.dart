import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/enums/avatar_shape.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/ui/widgets/user_avatar.dart';
import 'package:app/modules/core/ui/widgets/user_menu.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/core/ui/widgets/user_menu_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/core/ui/widgets/organization_select.dart';

class MainHeader extends StatefulWidget {
  final Widget? leading;
  
  const MainHeader({
    super.key,
    this.leading,
  });

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  final popoverController = ShadPopoverController();

  void _handleAvatarClick(BuildContext context, UserData userData, bool isMobile) {
    if (isMobile) {
      showShadSheet(
        context: context,
        side: ShadSheetSide.right,
        builder: (context) => UserMenuSheet(userData: userData),
      );
    } else {
      popoverController.toggle();
    }
  }

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 850;
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) return const SizedBox.shrink();
        
        return Container(
          height: 52,
          padding: sl<LayoutBloc>().state.layoutType == LayoutType.mobile 
                    ? const EdgeInsets.fromLTRB(12, 0, 16, 0) 
                    : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(
              bottom: BorderSide(
                color: colors.muted,
                width: 1,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Optional Leading Widget
              if (widget.leading != null)
                Positioned(
                  left: 0,
                  child: widget.leading!,
                ),

              // Logo - left-aligned on desktop, centered on mobile
              // BlocBuilder<LayoutBloc, LayoutState>(
              //   builder: (context, state) {
              //     final isMobile = state.layoutType == LayoutType.mobile;
              //     return Positioned(
              //       left: isMobile ? null : (widget.leading != null ? 48 : 0),
              //       child: Image.asset(
              //         width: 150,
              //         ShadTheme.of(context).brightness == Brightness.dark
              //           ? 'assets/img/pb_logo_full_white.png'
              //           : 'assets/img/pb_logo_full_black.png',
              //         height: 25,
              //       ),

              //     );
              //   },
              // ),

              // Right-side icons
              BlocBuilder<LayoutBloc, LayoutState>(
                builder: (context, state) {
                  final isMobile = state.layoutType == LayoutType.mobile;
                  
                  if (isMobile) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: UserAvatar(
                        onClick: () => _handleAvatarClick(context, authState.userData, true),
                        shape: AvatarShape.roundedRectangle,
                      ),
                    );
                  }
                  
                  return Positioned(
                    right: 0,
                    child: Row(
                      children: [
                        IconButton(
                          iconSize: 20,
                          icon: ShadImage(
                            LucideIcons.idCard,
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            color: colors.mutedForeground,
                          ),
                          onPressed: () => context.go('/agents'),
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: ShadImage(
                            LucideIcons.compass,
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            color: colors.mutedForeground,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: ShadImage(
                            LucideIcons.library,
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            color: colors.mutedForeground,
                          ),    
                          onPressed: () => context.go('/library'),
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: ShadImage(
                            LucideIcons.bell,
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            color: colors.mutedForeground,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        VerticalDivider(
                          indent: 14,
                          endIndent: 14,
                          color: colors.border,
                        ),
                        const SizedBox(width: 8),
                        ShadPopover(
                          controller: popoverController,
                          popover: (context) => UserMenu(
                            userData: authState.userData, 
                            onItemClick: () => popoverController.toggle()
                          ),
                          child: UserAvatar(
                            onClick: () => _handleAvatarClick(context, authState.userData, false),
                            shape: AvatarShape.roundedRectangle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // if (isDesktop) 
              //   Positioned(
              //     left: 170,
              //     right: 205,
              //     child: Center(
              //       child: const OrganizationSelect(),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }
}