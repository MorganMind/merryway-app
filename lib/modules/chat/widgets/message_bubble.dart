// import 'dart:convert';
// import 'package:app/config/environment.dart';
// import 'package:app/modules/chat/models/message.dart';
// import 'package:app/modules/chat/models/message_sender.dart';
// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:app/modules/tags/blocs/tags_bloc.dart';
// import 'package:app/modules/tags/blocs/tags_event.dart';
// import 'package:app/modules/tags/blocs/tags_state.dart';
// import 'package:app/modules/tags/models/taggable_type.dart';
// import 'package:flutter/material.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// class MessageBubble extends StatefulWidget {
//   final Message message;

//   const MessageBubble({
//     Key? key,
//     required this.message,
//   }) : super(key: key);

//   @override
//   State<MessageBubble> createState() => _MessageBubbleState();
// }

// class _MessageBubbleState extends State<MessageBubble> {
//   bool _hasLoadedTags = false;

//   @override
//   Widget build(BuildContext context) {
//     final isUser = widget.message.sender == MessageSender.user;
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           // Debug Accordion - only shown in development
//           if (Environment.isDevelopment)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: BlocListener<TagsBloc, TagsState>(
//                 listener: (context, state) {
//                   if (state is ItemTagsLoaded && state.taggableId == widget.message.id) {
//                     _hasLoadedTags = true;
//                   }
//                 },
//                 child: ShadAccordion<String>(
//                   children: [
//                     ShadAccordionItem(
//                       separator: const SizedBox(height: 0),
//                       value: 'debug',
//                       title: SelectableText(
//                         'debug',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: colors.mutedForeground,
//                         ),
//                       ),
//                       child: BlocBuilder<TagsBloc, TagsState>(
//                         builder: (context, tagsState) {
//                           if (!_hasLoadedTags) {
//                             final bloc = context.read<TagsBloc>();
//                             _hasLoadedTags = true;
                           
//                             // Load tags on first expansion
//                             Future.microtask(() {
//                               bloc.add(LoadTaggingsForItem(
//                                 taggableType: TaggableType.message,
//                                 taggableId: widget.message.id,
//                               ));
//                             });
//                           }
                          
//                           return Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: colors.muted,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: SelectableText(
//                               JsonEncoder.withIndent('  ').convert({
//                                 'topicId': widget.message.topicId,
//                                 'metadata': {
//                                   'sentiment': widget.message.metadata?.sentiment.toString().split('.').last,
//                                   'intent': widget.message.metadata?.intent.toString().split('.').last,
//                                   'confidence': widget.message.metadata?.confidence,
//                                   'potentialActions': widget.message.metadata?.potentialActions
//                                       .map((a) => {
//                                             'actionType': a.actionType,
//                                             'description': a.description,
//                                             'confidence': a.confidence,
//                                             'targetAgentId': a.targetAgentId,
//                                             'context': a.context,
//                                           })
//                                       .toList(),
//                                   'topicTransitions': widget.message.metadata?.topicTransitions,
//                                 },
//                                 'context': widget.message.context,
//                                 'tags': tagsState is ItemTagsLoaded && 
//                                        tagsState.taggableId == widget.message.id
//                                     ? tagsState.tags.map((t) => {
//                                         'id': t.id,
//                                         'label': t.label,
//                                       }).toList()
//                                     : [],
//                               }),
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontFamily: 'monospace',
//                                 color: colors.foreground,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
          
//           // Message bubble
//           Row(
//             mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!isUser) CircleAvatar(
//                 radius: 16,
//                 backgroundColor: colors.muted,
//                 // backgroundImage: message.sender avatar URL when we have it
//               ),
//               const SizedBox(width: 8),
//               Flexible(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.7,
//                   ),
//                   padding: isUser 
//                     ? const EdgeInsets.all(12) 
//                     : const EdgeInsets.fromLTRB(12, 0, 12, 12),
//                   decoration: BoxDecoration(
//                     color: isUser ? colors.secondary : Colors.transparent,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: MarkdownBody(
//                     data: widget.message.content,
//                     selectable: true,
//                     styleSheet: MarkdownStyleSheet(
//                       p: TextStyle(
//                         color: colors.foreground,
//                       ),
//                       code: TextStyle(
//                         color: colors.foreground,
//                         backgroundColor: colors.muted,
//                       ),
//                       codeblockDecoration: BoxDecoration(
//                         color: colors.muted,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// } 