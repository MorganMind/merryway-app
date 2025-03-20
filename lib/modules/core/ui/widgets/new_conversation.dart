// import 'package:app/modules/agents/models/agent.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:app/modules/agents/blocs/agents_bloc.dart';
// import 'package:app/modules/agents/blocs/agents_event.dart';
// import 'package:app/modules/core/ui/widgets/agent_avatar.dart';
// import 'package:app/modules/core/enums/avatar_shape.dart';
// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:go_router/go_router.dart';

// class NewConversation extends StatelessWidget {
//   final List<Agent> agents;

//   const NewConversation({
//     super.key,
//     required this.agents,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;
    
//     return SingleChildScrollView(
//       child: SizedBox(
//         width: 375,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'New Conversation',
//                 style: theme.textTheme.h4.copyWith(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: colors.foreground,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Select the personnel to start a new conversation',
//                 style: theme.textTheme.muted.copyWith(
//                   fontSize: 14,
//                   color: colors.mutedForeground,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               ShadInput(
//                 placeholder: const Text('Search'),
//                 style: TextStyle(color: colors.foreground),
//               ),
//               const SizedBox(height: 16),
//               Column(
//                 children: agents.map((agent) {
//                   return _AgentListItem(
//                     agent: agent,
//                     theme: theme,
//                     onStart: () {
//                       context.read<AgentsBloc>().add(CreateConversationWithCallback(
//                         agentId: agent.id,
//                         onSuccess: (updatedAgent) {
//                           context.go('/agent/${updatedAgent.id}');
//                         },
//                       ));
//                     },
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AgentListItem extends StatefulWidget {
//   final Agent agent;
//   final ShadThemeData theme;
//   final VoidCallback onStart;

//   const _AgentListItem({
//     required this.agent,
//     required this.theme,
//     required this.onStart,
//   });

//   @override
//   State<_AgentListItem> createState() => _AgentListItemState();
// }

// class _AgentListItemState extends State<_AgentListItem> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appTheme;
    
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _isHovered = true),
//         onExit: (_) => setState(() => _isHovered = false),
//         child: Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: _isHovered ? colors.secondary : colors.background,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               AgentAvatar(
//                 agent: widget.agent,
//                 shape: AvatarShape.circle,
//                 size: const Size(40, 40),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.agent.name,
//                   style: widget.theme.textTheme.p.copyWith(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                     color: colors.foreground,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               ShadButton(
//                 onPressed: widget.onStart,
//                 child: Text(
//                   'Start',
//                   style: TextStyle(color: colors.primaryForeground),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// } 