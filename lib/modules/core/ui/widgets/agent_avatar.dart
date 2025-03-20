// import 'package:app/modules/core/ui/widgets/base_avatar.dart';
// import 'package:flutter/material.dart';
// import 'package:app/modules/core/enums/avatar_shape.dart';
// import 'package:app/modules/agents/models/agent.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';

// class AgentAvatar extends StatelessWidget {
//   final Agent agent;
//   final AvatarShape shape;
//   final Size? size;

//   const AgentAvatar({
//     super.key,
//     required this.agent,
//     this.shape = AvatarShape.roundedSquare,
//     this.size,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BaseAvatar(
//       agent.avatarUrl ?? LucideIcons.creditCard,
//       placeholder: Text(agent.name[0]),
//       backgroundColor: const Color(0xFFF4F4F5),
//       size: size ?? shape.size,
//       shape: shape.shapeBorder,
//       fit: BoxFit.cover,
//     );
//   }
// } 