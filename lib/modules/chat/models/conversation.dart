// import 'package:app/modules/chat/models/attachments.dart';
// import 'package:app/modules/chat/models/message.dart';

// class Conversation {
//   final String id;
//   final String userId;
//   final String agentId;
//   final String description;
//   final DateTime? createdAt;
//   final List<Message> messages;
//   final List<ConversationAttachment> attachments;

//   String? get lastMessage => messages.isNotEmpty 
//     ? messages.last.content 
//     : null;

//   DateTime? get lastMessageAt => messages.isNotEmpty 
//     ? messages.last.createdAt 
//     : null;

//   Conversation({
//     required this.id,
//     required this.userId,
//     required this.agentId,
//     required this.description,
//     this.createdAt,
//     List<Message>? messages,
//     List<ConversationAttachment>? attachments,
//   })  : messages = messages ?? [],
//         attachments = attachments ?? [];

//   factory Conversation.fromJson(Map<String, dynamic> json) {
//     return Conversation(
//       id: json['id'],
//       userId: json['user_id'],
//       agentId: json['agent_id'],
//       description: json['description'],
//       createdAt: json['created_at'] != null 
//         ? DateTime.parse(json['created_at']) 
//         : null,
//       messages: json['messages'] != null
//           ? (json['messages'] as List)
//               .map((msg) => Message.fromJson(msg))
//               .toList()
//           : [],
//       attachments: json['attachments'] != null
//           ? (json['attachments'] as List)
//               .map((att) => ConversationAttachment.fromJson(att))
//               .toList()
//           : [],
//     );
//   }
// }