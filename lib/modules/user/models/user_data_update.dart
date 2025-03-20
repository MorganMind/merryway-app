class UserDataUpdate {
  final String? fullName;

  const UserDataUpdate({
    this.fullName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    return map;
  }
} 