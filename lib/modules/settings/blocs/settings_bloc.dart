import 'dart:async';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/settings/blocs/settings_event.dart';
import 'package:app/modules/settings/blocs/settings_state.dart';
import 'package:app/modules/user/models/user_settings_update.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/user/repositories/user_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserSettingsRepository _settingsRepository = sl<UserSettingsRepository>();
  final UserRepository _userRepository = sl<UserRepository>();
  StreamSubscription? _settingsSubscription;

  SettingsBloc() : super(SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    // on<UpdateLastUsed>(_onUpdateLastUsed);
    on<UpdateUserData>(_onUpdateUserData);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      await _settingsRepository.initializeSettingsStream();
      
      await _settingsSubscription?.cancel();
      _settingsSubscription = _settingsRepository.settings.listen(
        (settings) => add(UpdateSettings(UserSettingsUpdate())),
        onError: (error) => emit(state.copyWith(error: error.toString(), isLoading: false)),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final settings = await _settingsRepository.updateSettings(event.update);
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onUpdateUserData(
    UpdateUserData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final userData = await _userRepository.updateUserData(event.update);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  // Future<void> _onUpdateLastUsed(
  //   UpdateLastUsed event,
  //   Emitter<SettingsState> emit,
  // ) async {
  //   try {
  //     final updatedSettings = await _settingsRepository.updateLastUsed(event.update);
      
  //     emit(state.copyWith(
  //       settings: updatedSettings,
  //       error: null,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(error: e.toString()));
  //   }
  // }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    _settingsRepository.dispose();
    return super.close();
  }
} 