// class ConversationAttachment {
//   final String id;
//   final String conversationId;
//   final String type;
//   final String url;
//   final String fileType;

//   ConversationAttachment({
//     required this.id,
//     required this.conversationId,
//     required this.type,
//     required this.url,
//     required this.fileType,
//   });

//   factory ConversationAttachment.fromJson(Map<String, dynamic> json) {
//     return ConversationAttachment(
//       id: json['id'],
//       conversationId: json['conversation_id'],
//       type: json['type'],
//       fileType: json['file_type'],
//       url: json['url'],
//     );
//   }
// }

// class MessageAttachment {
//   final String id;
//   final String messageId;
//   final String type;
//   final String url;
//   final String fileType;

//   MessageAttachment({
//     required this.id,
//     required this.messageId,
//     required this.type,
//     required this.url,
//     required this.fileType,
//   });

//   factory MessageAttachment.fromJson(Map<String, dynamic> json) {
//     return MessageAttachment(
//       id: json['id'],
//       messageId: json['message_id'],
//       type: json['type'],
//       fileType: json['file_type'],
//       url: json['url'],
//     );
//   }
// }