import 'package:app/modules/core/enums/avatar_type.dart';
import 'package:equatable/equatable.dart';

enum UpdateFrequency {
  realtime,
  batched,
  daily,
  disabled,
}

enum ThemeMode {
  light,
  dark,
}

class UserSettings extends Equatable {
  final String userId;
  final AvatarType avatarType;
  final ThemeMode theme;

  const UserSettings({
    required this.userId,
    this.avatarType = AvatarType.upload,
    this.theme = ThemeMode.light,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'],
      avatarType: AvatarType.values.firstWhere(
        (e) => e.toString().split('.').last == json['avatar_type'],
        orElse: () => AvatarType.icon,
      ),
      theme: ThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['theme'],
        orElse: () => ThemeMode.light,
      ),
    );
  }

  static const empty = UserSettings(userId: '');

  @override
  List<Object?> get props => [
        userId,
        avatarType,
        theme,
      ];
} 