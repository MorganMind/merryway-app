import 'package:app/modules/user/models/user_data_update.dart';
import 'package:app/modules/user/models/user_settings_update.dart';
// import 'package:app/modules/user/models/last_used_update.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {}

class LoadSettings extends SettingsEvent {
  final String userId;
  LoadSettings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateSettings extends SettingsEvent {
  final UserSettingsUpdate update;
  UpdateSettings(this.update);

  @override
  List<Object?> get props => [update];
}

// class UpdateLastUsed extends SettingsEvent {
//   final LastUsedUpdate update;

//   UpdateLastUsed(this.update);

//   @override
//   List<Object?> get props => [update];
// }

class UpdateUserData extends SettingsEvent {
  final UserDataUpdate update;
  UpdateUserData(this.update);

  @override
  List<Object?> get props => [update];
}

