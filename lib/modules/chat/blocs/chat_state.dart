// import 'package:equatable/equatable.dart';
// import 'package:app/modules/chat/models/message.dart';

// abstract class ChatState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class ChatInitial extends ChatState {}

// class ChatLoading extends ChatState {}

// class ChatLoaded extends ChatState {
//   final List<Message> messages;
//   final String? streamingMessage;
  
//   ChatLoaded(this.messages, {this.streamingMessage});
  
//   ChatLoaded copyWith({
//     List<Message>? messages,
//     String? streamingMessage,
//   }) {
//     return ChatLoaded(
//       messages ?? this.messages,
//       streamingMessage: streamingMessage ?? this.streamingMessage,
//     );
//   }
  
//   @override
//   List<Object?> get props => [messages, streamingMessage];
// }

// class ChatError extends ChatState {
//   final String message;
  
//   ChatError(this.message);
  
//   @override
//   List<Object?> get props => [message];
// }
