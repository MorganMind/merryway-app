import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:app/modules/user/models/user_settings_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/settings/widgets/avatar_type_selector.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/user/models/user_data_update.dart';
import 'package:app/modules/settings/blocs/settings_event.dart';
import 'package:app/modules/settings/blocs/settings_bloc.dart';
import 'package:watch_it/watch_it.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:app/modules/core/enums/avatar_type.dart';
import 'dart:async';

class AboutYouPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AboutYouPage({super.key});

  @override
  State<AboutYouPage> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends State<AboutYouPage>   {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Add debounce timers
  Timer? _nameDebounceTimer;
  Timer? _roleDebounceTimer;
  Timer? _locationDebounceTimer;
  Timer? _bioDebounceTimer;
  
  // Track last saved values
  String? _lastSavedName;
  String? _lastSavedRole;
  String? _lastSavedLocation;
  String? _lastSavedBio;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    
    // Cancel any active timers
    _nameDebounceTimer?.cancel();
    _roleDebounceTimer?.cancel();
    _locationDebounceTimer?.cancel();
    _bioDebounceTimer?.cancel();
    
    super.dispose();
  }

  void _handleNameChanged(String newValue) {
    if (_nameDebounceTimer?.isActive ?? false) _nameDebounceTimer!.cancel();
    
    _nameDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (newValue != _lastSavedName) {
        sl<SettingsBloc>().add(
          UpdateUserData(
            UserDataUpdate(fullName: newValue),
          ),
        );
        _lastSavedName = newValue;
      }
    });
  }

  // void _handleRoleChanged(String newValue) {
  //   if (_roleDebounceTimer?.isActive ?? false) _roleDebounceTimer!.cancel();
    
  //   _roleDebounceTimer = Timer(const Duration(seconds: 2), () {
  //     if (newValue != _lastSavedRole) {
  //       sl<SettingsBloc>().add(
  //         UpdateUserData(
  //           UserDataUpdate(role: newValue),
  //         ),
  //       );
  //       _lastSavedRole = newValue;
  //     }
  //   });
  // }

  // void _handleLocationChanged(String newValue) {
  //   if (_locationDebounceTimer?.isActive ?? false) _locationDebounceTimer!.cancel();
    
  //   _locationDebounceTimer = Timer(const Duration(seconds: 2), () {
  //     if (newValue != _lastSavedLocation) {
  //       sl<SettingsBloc>().add(
  //         UpdateUserData(
  //           UserDataUpdate(location: newValue),
  //         ),
  //       );
  //       _lastSavedLocation = newValue;
  //     }
  //   });
  // }

  // void _handleBioChanged(String newValue) {
  //   if (_bioDebounceTimer?.isActive ?? false) _bioDebounceTimer!.cancel();
    
  //   _bioDebounceTimer = Timer(const Duration(seconds: 2), () {
  //     if (newValue != _lastSavedBio) {
  //       sl<SettingsBloc>().add(
  //         UpdateUserData(
  //           UserDataUpdate(bio: newValue),
  //         ),
  //       );
  //       _lastSavedBio = newValue;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;

    // Watch the settings stream
    final settings = watchStream(
      (UserSettingsRepository r) => r.settings,
      initialValue: sl<UserSettingsRepository>().currentSettings,
    ).data;
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox();

        // Update controllers and last saved values with current values
        _lastSavedName = state.userData.fullName;
        // _lastSavedRole = state.userData.role;
        // _lastSavedLocation = state.userData.location;
        // _lastSavedBio = state.userData.bio;
        
        _nameController.text = state.userData.fullName ?? '';
        _emailController.text = state.userData.email;
        // _roleController.text = state.userData.role ?? '';
        // _locationController.text = state.userData.location ?? '';
        // _bioController.text = state.userData.bio ?? '';

        final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

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
                          'About You',
                          style: theme.textTheme.h3.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help Morgan understand you for a more tailored experience',
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
                    AvatarTypeSelector(
                      selectedType: settings?.avatarType ?? AvatarType.upload,
                      onSelect: (type) {
                        sl<UserSettingsRepository>().updateSettings(UserSettingsUpdate(avatarType: type));
                      },
                    ),
                    const SizedBox(height: 24), 
                    Row(
                      children: [
                        Expanded(
                          child: ShadInputFormField(
                            controller: _nameController,
                            label: Text('Full Name', style: TextStyle(color: colors.foreground)),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.foreground,
                            ),
                            description: Text(
                              isMobile ? ' ' : 'Your personnel and team members see this name',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.mutedForeground,
                              ),
                            ),
                            onChanged: _handleNameChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ShadInputFormField(
                            controller: _emailController,
                            label: Text('Email', style: TextStyle(color: colors.foreground)),
                            description: const Text(' ', style: TextStyle(fontSize: 12)),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.mutedForeground,
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ShadInputFormField(
                    //         controller: _roleController,
                    //         label: isMobile 
                    //           ? Text('Role', style: TextStyle(color: colors.foreground)) 
                    //           : Text('Role (Title in Organization)', style: TextStyle(color: colors.foreground)),
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           color: colors.foreground,
                    //         ),
                    //         onChanged: _handleRoleChanged,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: ShadInputFormField(
                    //         controller: _locationController,
                    //         label: Text('Location', style: TextStyle(color: colors.foreground)),
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           color: colors.foreground,
                    //         ),
                    //         onChanged: _handleLocationChanged,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 16),
                    // Stack(
                    //   children: [
                    //     ShadInputFormField(
                    //       controller: _bioController,
                    //       label: Text('Bio', style: TextStyle(color: colors.foreground)),
                    //       description: Text(
                    //         'Tell Morgan a little bit about yourself.',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: colors.mutedForeground,
                    //         ),
                    //       ),
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w400,
                    //         color: colors.foreground,
                    //       ),
                    //       maxLines: 4,
                    //       onChanged: _handleBioChanged,
                    //     ),
                    //     Positioned(
                    //       bottom: 36,
                    //       right: 10,
                    //       child: AudioRecorderButton(
                    //         showBackground: true,
                    //         iconSize: 20,
                    //         onTranscriptionComplete: (transcription) {
                    //           final currentText = _bioController.text;
                    //           final newText = currentText.isEmpty 
                    //             ? transcription 
                    //             : '$currentText\n$transcription';
                              
                    //           _bioController.text = newText;
                    //           _handleBioChanged(newText);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ); 
  }
} 