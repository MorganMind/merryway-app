import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminPanel extends StatefulWidget {
  final bool isMobile;
  
  const AdminPanel({
    super.key,
    required this.isMobile,
  });

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? _selectedSection;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedSection != null)
            // Section Header with Back Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      color: colors.mutedForeground,
                    ),
                    onPressed: () => setState(() => _selectedSection = null),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedSection!,
                    style: theme.textTheme.h3.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            )
          else
            // Main Menu Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Admin Panel',
                style: theme.textTheme.h3.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),

          // Content
          Expanded(
            child: _selectedSection != null
                ? _buildSectionContent()
                : _buildMainMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    final colors = context.appTheme;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadButton.ghost(
            onPressed: () => setState(() => _selectedSection = 'Agents'),
            child: Row(
              children: [
                Icon(
                  LucideIcons.users,
                  size: 16,
                  color: colors.foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  'Agents',
                  style: TextStyle(
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),
          // Add more menu buttons here
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      // case 'Agents':
      //   return const Padding(
      //     padding: EdgeInsets.all(16),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         AgentAdmin(),
      //       ],
      //     ),
      //   );
      default:
        return const SizedBox();
    }
  }
} 