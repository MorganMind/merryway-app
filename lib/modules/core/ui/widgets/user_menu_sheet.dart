import 'package:app/modules/core/ui/widgets/user_menu.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserMenuSheet extends StatelessWidget {
  final UserData userData;

  const UserMenuSheet({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return ShadSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: UserMenu(
        userData: userData,
        onItemClick: () {
          Navigator.of(context).pop(); // Close the sheet
        },
      ),
    );
  }
} 