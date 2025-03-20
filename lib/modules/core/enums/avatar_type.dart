enum AvatarType {
  icon,
  caricature,
  upload;

  factory AvatarType.fromString(String value) {
    return AvatarType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => AvatarType.icon,
    );
  }
}