// import 'package:app/modules/chat/models/attachments.dart';
// import 'package:app/modules/chat/models/message_sender.dart';
// import 'package:app/modules/chat/models/message_metadata.dart';

// class Message {
//   final String id;
//   final MessageSender sender;
//   final String content;
//   final DateTime createdAt;
//   final String conversationId;
//   final String userId;
//   final List<MessageAttachment> attachments;
//   final String? topicId;
//   final MessageMetadata? metadata;
//   final List<Map<String, dynamic>>? context;

//   Message({
//     required this.id,
//     required this.sender,
//     required this.content,
//     required this.createdAt,
//     required this.conversationId,
//     required this.userId,
//     this.topicId,
//     this.metadata,
//     List<MessageAttachment>? attachments,
//     this.context,
//   }) : attachments = attachments ?? [];


//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       sender: MessageSender.fromJson(json['sender']),
//       content: json['content'],
//       createdAt: json['created_at'] != null 
//           ? DateTime.parse(json['created_at'])
//           : DateTime.now(),
//       conversationId: json['conversation_id'],
//       userId: json['user_id'],
//       topicId: json['topic_id'],
//       metadata: json['metadata'] != null 
//           ? MessageMetadata.fromJson(json['metadata'])
//           : null,
//       attachments: json['attachments'] != null
//           ? (json['attachments'] as List)
//               .map((att) => MessageAttachment.fromJson(att))
//               .toList()
//           : [],
//     );
//   }
// }