import 'package:app/modules/user/models/user_settings.dart';

class SettingsState {
  final UserSettings? settings;
  final bool isLoading;
  final String? error;
  
  SettingsState({
    this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    UserSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}