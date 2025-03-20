// import 'package:app/modules/chat/models/conversation.dart';
// import 'package:app/modules/core/services/api/i_api_service.dart';
// import 'package:app/modules/core/di/service_locator.dart';

// abstract class IChatRepository {
//   Future<Conversation> createConversation(String agentId);
// }

// class ChatRepository implements IChatRepository {
//   final IApiService _apiService = sl<IApiService>();

//   @override
//   Future<Conversation> createConversation(String agentId) async {
//     final response = await _apiService.request(
//       endpoint: 'conversations/create',
//       method: 'POST',
//       body: {'agent_id': agentId},
//       fromJson: (json) => Conversation.fromJson(json),
//     );

//     return response;
//   }
// } 