// import 'package:equatable/equatable.dart';

// abstract class ChatEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadMessages extends ChatEvent {
//   final String conversationId;
//   LoadMessages(this.conversationId);
// }

// class SendMessage extends ChatEvent {
//   final String content;
//   final String conversationId;
//   final String agentId;
//   final String organizationId;
//   SendMessage({required this.content, required this.conversationId, required this.agentId, required this.organizationId});
// }

// class MessageStreamReceived extends ChatEvent {
//   final String partialMessage;
//   final bool isComplete;
  
//   MessageStreamReceived(this.partialMessage, {this.isComplete = false});
  
//   @override
//   List<Object?> get props => [partialMessage, isComplete];
// }
