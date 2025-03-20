import 'package:app/modules/core/enums/avatar_type.dart';
import 'package:app/modules/user/models/user_settings.dart';

class UserSettingsUpdate {
  final AvatarType? avatarType;
  final ThemeMode? theme;

  const UserSettingsUpdate({
    this.avatarType,
    this.theme,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (avatarType != null) map['avatar_type'] = avatarType.toString().split('.').last;
    if (theme != null) map['theme'] = theme.toString().split('.').last;
    return map;
  }
} 