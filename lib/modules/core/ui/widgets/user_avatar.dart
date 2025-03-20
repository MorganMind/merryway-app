import 'package:app/modules/core/ui/widgets/base_avatar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/core/enums/avatar_shape.dart';
import 'package:shadcn_ui/src/utils/debug_check.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';

class UserAvatar extends StatelessWidget {
  final VoidCallback? onClick;
  final AvatarShape shape;

  const UserAvatar({
    super.key, 
    this.onClick,
    this.shape = AvatarShape.roundedSquare,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();
        
        return MouseRegion(
          cursor: onClick != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: onClick,
            child: BaseAvatar(
              state.userData.avatarUrl ?? 'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
              placeholder: Text(state.userData.firstName?[0] ?? 'U'),
              backgroundColor: const Color(0xFFF4F4F5),
              size: shape.size,
              shape: shape.shapeBorder,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
} 