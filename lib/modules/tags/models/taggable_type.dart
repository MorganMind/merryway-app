enum TaggableType {
  message,
  conversation,
  agent;

  factory TaggableType.fromString(String value) {
    return TaggableType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TaggableType.message,
    );
  }
} 