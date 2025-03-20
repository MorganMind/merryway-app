import 'dart:async';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/services/api/i_api_service.dart';
import 'package:app/modules/user/models/user_settings.dart';
import 'package:app/modules/user/models/user_settings_update.dart';

class UserSettingsRepository {
  final IApiService _apiService = sl<IApiService>();
  
  UserSettings _cachedSettings = UserSettings.empty;
  ThemeMode _cachedTheme = ThemeMode.light;
  bool _hasInitialSettings = false;

  final _settingsController = StreamController<UserSettings>.broadcast();
  final _themeController = StreamController<ThemeMode>.broadcast();
  final _initialSettingsLoadedController = StreamController<void>.broadcast();

  Stream<UserSettings> get settings => _settingsController.stream;
  Stream<ThemeMode> get theme => _themeController.stream;
  Stream<void> get initialSettingsLoaded => _initialSettingsLoadedController.stream;

  UserSettings? get currentSettings => _cachedSettings;
  ThemeMode get currentTheme => _cachedTheme;

  UserSettingsRepository() {
    _settingsController.stream.listen((settings) {
      final newTheme = settings.theme;
      
      // Only emit theme if changed
      if (_cachedTheme != newTheme) {
        _cachedTheme = newTheme;
        _themeController.add(newTheme);
      }
      
      // Signal initial settings load or reinitialization
      // if (!_hasInitialSettings && settings.lastOrganizationId != null) {
      //   _hasInitialSettings = true;
      //   _initialSettingsLoadedController.add(null);
      // }
    });
  }

  Future<void> reinitializeSettingsStream() async {
    //_hasInitialSettings = false;
    return initializeSettingsStream();
  }

  Future<void> initializeSettingsStream() async {
   
    //await _settingsSubscription?.cancel();
    
    try {
      // Get initial settings
      final settings = await _apiService.request(
        endpoint: '/settings',
        method: 'GET',
        fromJson: (json) => UserSettings.fromJson(json),
      );

      _cachedSettings = settings;
      if (!_settingsController.isClosed) {
        _settingsController.add(settings);
      }

      // Subscribe to realtime updates
      // _settingsSubscription = _supabase
      //     .from('user_settings')
      //     .stream(primaryKey: ['user_id'])
      //     .eq('user_id', userId)
      //     .map((event) {
      //       if (event.isEmpty) return _cachedSettings;
      //       try {
      //         final firstEvent = event.first;
      //         if (firstEvent == null) return _cachedSettings;
      //         return UserSettings.fromJson(firstEvent);
      //       } catch (e) {
      //         print('UserSettingsRepository: Error mapping stream event: $e');
      //         return _cachedSettings;
      //       }
      //     })
      //     .handleError((error) {
      //       print('UserSettingsRepository: Stream error: $error');
      //       return _cachedSettings;
      //     }, test: (error) => true)
      //     .listen(
      //       (settings) {
      //         _cachedSettings = settings;
      //         if (!_controller.isClosed) {
      //           _controller.add(settings);
      //         }
      //       },
      //       onError: (error) {
      //         print('UserSettingsRepository: Unhandled stream error: $error');
      //       },
      //       cancelOnError: false,
      //    );
    } catch (e) {
      print('UserSettingsRepository: Error initializing settings stream: $e');
      if (!_settingsController.isClosed) {
        _settingsController.addError(e);
      }
    }
  }

  Future<UserSettings> updateSettings(UserSettingsUpdate update) async {
    final updatedSettings = await _apiService.request(
      endpoint: '/settings/update',
      method: 'PATCH',
      body: update.toJson(),
      fromJson: (json) => UserSettings.fromJson(json),
    );

    _cachedSettings = updatedSettings;
    if (!_settingsController.isClosed) {
      _settingsController.add(updatedSettings);
    }
    
    return updatedSettings;
  }

  // Future<UserSettings> updateLastUsed(LastUsedUpdate update) async {
  //   try {
  //     final updatedSettings = await _apiService.request(
  //       endpoint: '/settings/update-last-used',
  //       method: 'POST',
  //       body: update.toJson(),
  //       fromJson: (json) => UserSettings.fromJson(json),
  //     );

  //     _cachedSettings = updatedSettings;
  //     if (!_settingsController.isClosed) {
  //       _settingsController.add(updatedSettings);
  //     }

  //     return updatedSettings;
  //   } catch (e) {
  //     throw 'Failed to update last used settings: $e';
  //   }
  // }

  Future<void> dispose() async {
    print('UserSettingsRepository: Disposing');
    _cachedSettings = UserSettings.empty;
    //await _settingsSubscription?.cancel();
    await _settingsController.close();
    await _themeController.close();
    await _initialSettingsLoadedController.close();
  }
} 