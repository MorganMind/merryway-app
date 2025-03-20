// import 'dart:async';
// import 'package:app/modules/chat/blocs/chat_event.dart';
// import 'package:app/modules/chat/blocs/chat_state.dart';
// import 'package:app/modules/chat/models/message.dart';
// import 'package:app/modules/chat/models/message_sender.dart';
// import 'package:app/modules/core/di/service_locator.dart';
// import 'package:app/modules/core/services/api/i_api_service.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';


// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final IApiService _apiService = sl<IApiService>();
  
//   ChatBloc() : super(ChatInitial()) {
//     on<LoadMessages>(_onLoadMessages);
//     on<SendMessage>(_onSendMessage);
//     on<MessageStreamReceived>(_onMessageStreamReceived);
//   }

//   Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
//     emit(ChatLoading());
//     try {
//       final messages = await _apiService.request<List<Message>>(
//         endpoint: 'conversations/${event.conversationId}/messages',
//         fromJson: (json) => (json['messages'] as List)
//             .map((m) => Message.fromJson(m))
//             .toList()
//             ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
//       );
      
//       emit(ChatLoaded(messages));
//     } catch (e) {
//       print('Error loading messages: $e');
//       emit(ChatError(e.toString()));
//     }
//   }

//   Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
//     try {
//       if (state is ChatLoaded) {
//         final currentMessages = (state as ChatLoaded).messages;
        
//         final userMessage = Message(
//           id: DateTime.now().toString(),
//           sender: MessageSender.user,
//           content: event.content,
//           createdAt: DateTime.now(),
//           conversationId: event.conversationId,
//           userId: 'user',
//         );
        
//         emit(ChatLoaded([...currentMessages, userMessage], streamingMessage: ''));

//         String buffer = '';
        
//         await for (final chunk in _apiService.streamRequest(
//           endpoint: 'chat', 
//           method: 'POST', 
//           body: {
//             'message': event.content, 
//             'conversation_id': event.conversationId,
//             'agent_id': event.agentId,
//             'organization_id': event.organizationId,
//           }
//         )) {
//           if (chunk.isNotEmpty) { 
//             buffer += chunk;
//             add(MessageStreamReceived(chunk));
//           }
//         }

//         if (buffer.isNotEmpty) {
//           final aiMessage = Message(
//             id: DateTime.now().toString(),
//             sender: MessageSender.agent,
//             content: buffer.trim(),
//             createdAt: DateTime.now(),
//             conversationId: event.conversationId,
//             userId: 'agent',
//           );
//           emit(ChatLoaded([...currentMessages, userMessage, aiMessage]));
//         }

//       }
//     } catch (e) {
//       print('Error sending message: $e');
//       emit(ChatError(e.toString()));
//     }
//   }

//   void _onMessageStreamReceived(MessageStreamReceived event, Emitter<ChatState> emit) {
//     if (state is ChatLoaded) {
//       final currentState = state as ChatLoaded;
//       final updatedStreamingMessage = (currentState.streamingMessage ?? '') + event.partialMessage;
//       emit(ChatLoaded(
//         currentState.messages,
//         streamingMessage: updatedStreamingMessage,
//       ));
//     }
//   }
// }
