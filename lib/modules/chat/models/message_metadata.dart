// import 'package:equatable/equatable.dart';

// enum MessageSentiment {
//   positive,
//   negative,
//   neutral;

//   factory MessageSentiment.fromString(String value) {
//     return MessageSentiment.values.firstWhere(
//       (e) => e.toString().split('.').last == value,
//       orElse: () => MessageSentiment.neutral,
//     );
//   }
// }

// enum MessageIntent {
//   question,
//   request_action,
//   inform,
//   clarify,
//   acknowledge,
//   implicit_request;

//   factory MessageIntent.fromString(String value) {
//     return MessageIntent.values.firstWhere(
//       (e) => e.toString().split('.').last == value.toLowerCase(),
//       orElse: () => MessageIntent.inform,
//     );
//   }
// }

// class PotentialAction extends Equatable {
//   final String actionType;
//   final String description;
//   final double confidence;
//   final String? targetAgentId;
//   final Map<String, dynamic> context;

//   const PotentialAction({
//     required this.actionType,
//     required this.description,
//     required this.confidence,
//     this.targetAgentId,
//     this.context = const {},
//   });

//   factory PotentialAction.fromJson(Map<String, dynamic> json) {
//     return PotentialAction(
//       actionType: json['action_type'],
//       description: json['description'],
//       confidence: json['confidence'].toDouble(),
//       targetAgentId: json['target_agent_id'],
//       context: json['context'] ?? {},
//     );
//   }

//   @override
//   List<Object?> get props => [actionType, description, confidence, targetAgentId, context];
// }

// class MessageMetadata extends Equatable {
//   final MessageSentiment sentiment;
//   final MessageIntent intent;
//   final double confidence;
//   final List<PotentialAction> potentialActions;
//   final List<String> topicTransitions;

//   const MessageMetadata({
//     required this.sentiment,
//     required this.intent,
//     required this.confidence,
//     this.potentialActions = const [],
//     this.topicTransitions = const [],
//   });

//   factory MessageMetadata.fromJson(Map<String, dynamic> json) {
//     return MessageMetadata(
//       sentiment: MessageSentiment.fromString(json['sentiment']),
//       intent: MessageIntent.fromString(json['intent']),
//       confidence: json['confidence'].toDouble(),
//       potentialActions: (json['potential_actions'] as List?)
//           ?.map((action) => PotentialAction.fromJson(action))
//           .toList() ?? [],
//       topicTransitions: (json['topic_transitions'] as List?)
//           ?.map((topic) => topic.toString())
//           .toList() ?? [],
//     );
//   }

//   @override
//   List<Object?> get props => [sentiment, intent, confidence, potentialActions, topicTransitions];
// }
