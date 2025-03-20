import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/core/ui/widgets/user_avatar.dart';
import 'package:app/modules/core/enums/avatar_shape.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_event.dart';
import 'package:app/modules/core/ui/widgets/admin_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMenu extends StatelessWidget {
  final UserData userData;
  final Function? onItemClick;
  
  const UserMenu({
    super.key,
    required this.userData,
    this.onItemClick,
  });


  void _handleLogout(BuildContext context) {
    sl<AuthBloc>().add(AuthSignOut());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    
    return SizedBox(
      width: 256,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Account',
              style: theme.textTheme.small.copyWith(
                color: colors.foreground,
              ),
              textAlign: TextAlign.left,
            ),
            
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const UserAvatar(shape: AvatarShape.roundedSquare),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.zero,
                            child: Text(
                              '${userData.firstName ?? ''} ${userData.lastName ?? ''}',
                              style: theme.textTheme.p.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: colors.foreground,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.zero,
                            child: Text(
                              userData.email,
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 12,
                                color: colors.mutedForeground,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border),

            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Row(
                children: [
                  ShadImage(LucideIcons.user, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Profile', style: theme.textTheme.p.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),
            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {
                context.go('/settings');
                if (onItemClick != null) {
                  onItemClick!();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.settings2, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Settings', style: theme.textTheme.p.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),
            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.star, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Upgrade to Premium', 
                    style: theme.textTheme.p.copyWith(
                      fontSize: 14, 
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border),

            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.userPlus, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Invite people', style: theme.textTheme.p.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),

            Divider(color: colors.border),

            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.apple, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Download MacOS App', style: theme.textTheme.p.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),
            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.lifeBuoy, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Support', style: theme.textTheme.p.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),

            Divider(color: colors.border),

            if (userData.email == 'producer999@gmail.com')
              ShadButton.ghost(
                height: 32,
                padding: EdgeInsets.zero,
                onPressed: () {
                  final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;
                  
                  if (isMobile) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      builder: (context) => const AdminPanel(isMobile: true),
                    );
                  } else {
                    showDialog(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          width: 800,
                          height: 600,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const AdminPanel(isMobile: false),
                        ),
                      ),
                    );
                  }

                  if (onItemClick != null) {
                    onItemClick!();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ShadImage(LucideIcons.shield, width: 16, height: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Admin', style: theme.textTheme.muted.copyWith(fontSize: 14, color: Colors.red)),
                  ],
                ),
              ),

            ShadButton.ghost(
              height: 32,
              padding: EdgeInsets.zero,
              onPressed: () => _handleLogout(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShadImage(LucideIcons.logOut, width: 16, height: 16, color: colors.foreground),
                  const SizedBox(width: 8),
                  Text('Log out', style: theme.textTheme.muted.copyWith(fontSize: 14, color: colors.foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 