class UserAnalytics {
  final String id;
  final String userId;
  final int totalTokens;
  final int promptTokens;
  final int completionTokens;
  final int messagesSent;
  final int agentsCount;
  final int uploadsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final empty = UserAnalytics(
    id: '',
    userId: '',
    totalTokens: 0,
    promptTokens: 0,
    completionTokens: 0,
    messagesSent: 0,
    agentsCount: 0,
    uploadsCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  UserAnalytics({
    required this.id,
    required this.userId,
    required this.totalTokens,
    required this.promptTokens,
    required this.completionTokens,
    required this.messagesSent,
    required this.agentsCount,
    required this.uploadsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      id: json['id'],
      userId: json['user_id'],
      totalTokens: json['total_tokens'] ?? 0,
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      messagesSent: json['messages_sent'] ?? 0,
      agentsCount: json['agents_count'] ?? 0,
      uploadsCount: json['uploads_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 