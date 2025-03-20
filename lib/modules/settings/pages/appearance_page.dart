import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/core/ui/widgets/m_select.dart';
import 'package:app/modules/settings/blocs/settings_bloc.dart';
import 'package:app/modules/settings/blocs/settings_event.dart';
import 'package:app/modules/settings/widgets/theme_mode_selector.dart';
import 'package:app/modules/user/models/user_settings_update.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:app/modules/user/models/user_settings.dart' as u;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:watch_it/watch_it.dart';

class AppearancePage extends StatelessWidget with WatchItMixin {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;
    final settings = watchStream(
      (UserSettingsRepository r) => r.settings,
      initialValue: sl<UserSettingsRepository>().currentSettings,
    ).data;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: isMobile ? const EdgeInsets.all(12.0) : const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 625),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: theme.textTheme.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customize the appearance of the app',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: colors.border,
                ),
                const SizedBox(height: 24),
                ThemeModeSelector(
                  selectedTheme: settings?.theme ?? u.ThemeMode.light,
                  onSelect: (theme) {
                    sl<UserSettingsRepository>().updateSettings(UserSettingsUpdate(theme: theme));
                  }
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversation Text Size',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // SizedBox(
                    //   width: 240,
                    //   child: MSelect<int>(
                    //     boxShadow: false,
                    //     placeholder: 'Select size',
                    //     initialValue: settings?.conversationTextSize ?? 12,
                    //     onChanged: (size) {
                    //       sl<SettingsBloc>().add(UpdateSettings(UserSettingsUpdate(conversationTextSize: size)));
                    //     },
                    //     options: const [
                    //       12, 14, 16
                    //     ].map((size) => ShadOption(
                    //         value: size, 
                    //         child: Text(
                    //           '$size',
                    //           style: TextStyle(
                    //             color: colors.foreground,
                    //           ),
                    //         ),
                    //       )
                    //     ).toList(),
                    //     selectedOptionBuilder: (context, value) {
                    //       return Text(
                    //         switch (value) {
                    //           12 => '12',
                    //           14 => '14',
                    //           16 => '16',
                    //           _ => '12'
                    //         },
                    //         style: TextStyle(
                    //           color: colors.foreground,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      'Set the font size of the text in conversations',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 