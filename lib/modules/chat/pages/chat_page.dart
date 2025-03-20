// import 'dart:async';

// import 'package:app/modules/agents/blocs/agents_bloc.dart';
// import 'package:app/modules/agents/blocs/agents_state.dart';
// import 'package:app/modules/chat/blocs/chat_bloc.dart';
// import 'package:app/modules/chat/blocs/chat_event.dart';
// import 'package:app/modules/chat/blocs/chat_state.dart';
// import 'package:app/modules/chat/models/message.dart';
// import 'package:app/modules/chat/models/message_sender.dart';
// import 'package:app/modules/chat/widgets/message_bubble.dart';
// import 'package:app/modules/chat/widgets/message_input.dart';
// import 'package:app/modules/core/blocs/layout_bloc.dart';
// import 'package:app/modules/core/blocs/layout_state.dart';
// import 'package:app/modules/core/di/service_locator.dart';
// import 'package:app/modules/organization/blocs/organization_bloc.dart';
// import 'package:app/modules/user/repositories/user_settings_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:app/modules/chat/widgets/empty_state.dart';
// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:collection/collection.dart';


// class ChatPage extends StatefulWidget {
//   final String conversationId;

//   const ChatPage({
//     Key? key,
//     required this.conversationId,
//   }) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ScrollController _scrollController = ScrollController();
//   final _popoverController = ShadPopoverController();
//   late final ChatBloc _chatBloc;
//   String? _currentConversationId;

//   @override
//   void initState() {
//     super.initState();
//     _currentConversationId = widget.conversationId;
//     _chatBloc = ChatBloc();
    
//     // Initial load
//     _loadMessages();

//     // Listen for organization changes
//     sl<OrganizationBloc>().stream.listen((orgState) {
//       if (orgState.currentOrganization != null && mounted) {
//         // Wait for agents to load before loading messages
//         final agentsBloc = sl<AgentsBloc>();
//         if (agentsBloc.state is AgentsLoaded) {
//           final agents = (agentsBloc.state as AgentsLoaded).agents;
//           // Find the agent we're navigating to
//           final targetAgentId = sl<UserSettingsRepository>()
//               .currentSettings
//               ?.lastAgentIds[orgState.currentOrganization!.id];
              
//           if (targetAgentId != null) {
//             final agent = agents.firstWhere(
//               (a) => a.id == targetAgentId,
//               orElse: () => agents.first,
//             );
//             // If agent has conversations, use the first one
//             if (agent.conversations.isNotEmpty) {
//               _currentConversationId = agent.conversations.first.id;
//               _loadMessages();
//             }
//           }
//         }
//       }
//     });
//   }

//   void _loadMessages() {
//     final agentsState = sl<AgentsBloc>().state;
//     print('ChatPage._loadMessages - AgentsState: ${agentsState.runtimeType}');
    
//     if (agentsState is AgentsLoaded) {
//       // Find the conversation in the current org's agents
//       final hasConversation = agentsState.agents.any((agent) => 
//         agent.conversations.any((conv) => conv.id == widget.conversationId)
//       );
      
//       print('ChatPage._loadMessages - Has conversation: $hasConversation, conversationId: ${widget.conversationId}');
      
//       if (hasConversation) {
//         _chatBloc.add(LoadMessages(widget.conversationId));
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(ChatPage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     print('ChatPage.didUpdateWidget - old: ${oldWidget.conversationId}, new: ${widget.conversationId}');
//     if (oldWidget.conversationId != widget.conversationId) {
//       _currentConversationId = widget.conversationId;
//       _loadMessages();
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _popoverController.dispose();
//     _chatBloc.close();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Widget _buildHeader(String agentName, String conversationDescription) {
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;
    
//     return Container(
//       height: 45,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: colors.background,
//         border: Border(
//           bottom: BorderSide(color: colors.border),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left side - Breadcrumb and description
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Breadcrumb
//               Row(
//                 children: [
//                   Text(
//                     'Chat',
//                     style: theme.textTheme.muted,
//                   ),
//                   Text(
//                     ' / ',
//                     style: theme.textTheme.muted,
//                   ),
//                   Text(
//                     agentName,
//                     style: theme.textTheme.small.copyWith(
//                       color: colors.foreground,
//                     ),
//                   ),
//                 ],
//               ),
//               // Conversation description
//               Text(
//                 conversationDescription,
//                 style: theme.textTheme.p.copyWith(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: colors.foreground,
//                 ),
//               ),
//             ],
//           ),

//           // Right side - Action buttons
//           Row(
//             children: [
//               IconButton(
//                 iconSize: 20,
//                 icon: ShadImage(
//                   LucideIcons.share2,
//                   width: 16,
//                   height: 16,
//                   color: colors.mutedForeground,
//                   alignment: Alignment.center,
//                 ),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 iconSize: 16,
//                 icon: ShadImage(
//                   LucideIcons.tag,
//                   width: 16,
//                   height: 16,
//                   color: colors.mutedForeground,
//                   alignment: Alignment.center,
//                 ),
//                 onPressed: () {},
//               ),
//               ShadPopover(
//                 controller: _popoverController,
//                 popover: (context) => SizedBox(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ShadButton.ghost(
//                         padding: EdgeInsets.zero,
//                         onPressed: () {
//                           // Handle delete
//                           _popoverController.toggle();
//                         },
//                         iconSize: const Size(16, 16),
//                         icon: const ShadImage(LucideIcons.trash),
//                         child: Text(
//                           'Delete',
//                           style: theme.textTheme.p.copyWith(
//                             color: theme.colorScheme.destructive,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 child: IconButton(
//                   iconSize: 16,
//                   icon: const ShadImage(
//                     LucideIcons.ellipsisVertical,
//                     width: 16,
//                     height: 16,
//                     alignment: Alignment.center,
//                   ),
//                   onPressed: _popoverController.toggle,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appTheme;
    
//     return BlocProvider.value(
//       value: _chatBloc,
//       child: BlocConsumer<ChatBloc, ChatState>(
//         listener: (context, state) {
//           if (state is ChatLoaded && 
//               (state.streamingMessage != null || 
//                state.messages.isNotEmpty)) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _scrollToBottom();
//             });
//           }
//         },
//         builder: (context, state) {
//           return BlocBuilder<AgentsBloc, AgentsState>(
//             builder: (context, agentsState) {
//               if (agentsState is AgentsLoaded) {
//                 // Try to find conversation
//                 final conversation = agentsState.agents
//                     .expand((agent) => agent.conversations)
//                     .firstWhereOrNull((conv) => conv.id == widget.conversationId);
                
//                 if (conversation == null) {
//                   return Center(
//                     child: Text("")
//                     // CircularProgressIndicator(
//                     //   color: colors.mutedForeground,
//                     // ),
//                   );
//                 }

//                 final agent = agentsState.agents.firstWhere(
//                   (agent) => agent.conversations.contains(conversation),
//                 );

//                 return Column(
//                   children: [
//                     if(sl<LayoutBloc>().state.layoutType != LayoutType.mobile)
//                       _buildHeader(agent.name, conversation.description),
//                     Expanded(
//                       child: Container(
//                         color: colors.background,
//                         child: Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: Column(
//                             children: [
//                               Expanded(
//                                 child: Builder(
//                                   builder: (context) {
//                                     if (state is ChatLoading) {
//                                       return Center(
//                                         child: CircularProgressIndicator(
//                                           color: colors.mutedForeground,
//                                         ),
//                                       );
//                                     }
                                    
//                                     if (state is ChatError) {
//                                       return Center(
//                                         child: Text(
//                                           'Error: ${state.message}',
//                                           style: TextStyle(color: colors.foreground),
//                                         ),
//                                       );
//                                     }
                                    
//                                     if (state is ChatLoaded) {
//                                       if (state.messages.isEmpty && state.streamingMessage == null) {
//                                         return ChatEmptyState(agent: agent);
//                                       }
//                                       return ListView.builder(
//                                         controller: _scrollController,
//                                         itemCount: state.messages.length + (state.streamingMessage != null ? 1 : 0),
//                                         itemBuilder: (context, index) {
//                                           if (index < state.messages.length) {
//                                             final message = state.messages[index];
//                                             return MessageBubble(message: message);
//                                           } else {
//                                             return MessageBubble(
//                                               message: Message(
//                                                 id: 'streaming',
//                                                 sender: MessageSender.agent,
//                                                 content: state.streamingMessage!,
//                                                 conversationId: widget.conversationId,
//                                                 userId: "widget.userId",
//                                                 createdAt: DateTime.now(),
//                                               ),
//                                             );
//                                           }
//                                         },
//                                       );
//                                     }
                                    
//                                     return const SizedBox();
//                                   },
//                                 ),
//                               ),
//                               MessageInput(
//                                 onSend: (content) {
//                                   _chatBloc.add(
//                                     SendMessage(
//                                       content: content,
//                                       conversationId: widget.conversationId,
//                                       agentId: agent.id,
//                                       organizationId: sl<OrganizationBloc>().state.currentOrganization?.id ?? '',
//                                     ),
//                                   );
//                                 },
//                                 agentName: agent.name,
//                                 agentId: agent.id,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: colors.mutedForeground,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }