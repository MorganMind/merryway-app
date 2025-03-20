// enum MessageSender {
//   agent,
//   user;

//   String toJson() => name;

//   static MessageSender fromJson(String json) {
//     return MessageSender.values.firstWhere(
//       (sender) => sender.name == json,
//       orElse: () => throw ArgumentError('Invalid MessageSender value: $json'),
//     );
//   }
// } 