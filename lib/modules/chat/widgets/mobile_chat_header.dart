// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';

// class MobileChatHeader extends StatefulWidget {
//   final String conversationId;

//   const MobileChatHeader({
//     Key? key,
//     required this.conversationId,
//   }) : super(key: key);

//   @override
//   State<MobileChatHeader> createState() => _MobileChatHeaderState();
// }

// class _MobileChatHeaderState extends State<MobileChatHeader> {
//   final _popoverController = ShadPopoverController();

//   @override
//   Widget build(BuildContext context) {
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;
    
//     return Container(
//       padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
//       decoration: BoxDecoration(
//         color: colors.background
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Agent avatar and info
//           // BlocBuilder<AgentsBloc, AgentsState>(
//           //   builder: (context, state) {
//           //     if (state is AgentsLoaded) {
//           //       // Find the agent for this conversation
//           //       final agent = state.agents.firstWhere(
//           //         (agent) => agent.conversations.any(
//           //           (conv) => conv.id == widget.conversationId
//           //         ),
//           //         orElse: () => throw Exception('Agent not found'),
//           //       );
                
//           //       return Row(
//           //         children: [
//           //           CircleAvatar(
//           //             backgroundColor: colors.primary,
//           //             radius: 20,
//           //             child: Text(
//           //               agent.name[0].toUpperCase(),
//           //               style: TextStyle(
//           //                 color: colors.primaryForeground,
//           //                 fontWeight: FontWeight.bold,
//           //               ),
//           //             ),
//           //           ),
//           //           const SizedBox(width: 12),
//           //           Column(
//           //             mainAxisAlignment: MainAxisAlignment.center,
//           //             crossAxisAlignment: CrossAxisAlignment.start,
//           //             children: [
//           //               Text(
//           //                 agent.name,
//           //                 style: TextStyle(
//           //                   fontSize: 16,
//           //                   fontWeight: FontWeight.bold,
//           //                   color: colors.foreground,
//           //                 ),
//           //               ),
//           //               Text(
//           //                 agent.job,
//           //                 style: TextStyle(
//           //                   fontSize: 12,
//           //                   color: colors.mutedForeground,
//           //                 ),
//           //               ),
//           //             ],
//           //           ),
//           //         ],
//           //       );
//           //     }
              
//           //     return Row(
//           //       children: [
//           //         CircleAvatar(
//           //           backgroundColor: colors.secondary,
//           //           radius: 20,
//           //         ),
//           //         const SizedBox(width: 12),
//           //         Column(
//           //           crossAxisAlignment: CrossAxisAlignment.start,
//           //           children: [
//           //             SizedBox(
//           //               width: 100,
//           //               height: 16,
//           //               child: DecoratedBox(
//           //                 decoration: BoxDecoration(
//           //                   color: colors.secondary,
//           //                   borderRadius: BorderRadius.all(Radius.circular(4)),
//           //                 ),
//           //               ),
//           //             ),
//           //             const SizedBox(height: 4),
//           //             SizedBox(
//           //               width: 60,
//           //               height: 12,
//           //               child: DecoratedBox(
//           //                 decoration: BoxDecoration(
//           //                   color: colors.secondary,
//           //                   borderRadius: BorderRadius.all(Radius.circular(4)),
//           //                 ),
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ],
//           //     );
//           //   },
//           // ),
          
//           // Action buttons
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   iconSize: 20,
//                   padding: EdgeInsets.zero,
//                   visualDensity: VisualDensity.compact,
//                   style: IconButton.styleFrom(
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   icon: ShadImage(
//                     LucideIcons.messageSquarePlus,
//                     width: 20,
//                     height: 20,
//                     alignment: Alignment.center,
//                     color: colors.mutedForeground,
//                   ),
//                   onPressed: () {},
//                 ),
//                 const SizedBox(width: 4),
//                 IconButton(
//                   iconSize: 20,
//                   padding: EdgeInsets.zero,
//                   visualDensity: VisualDensity.compact,
//                   style: IconButton.styleFrom(
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   icon: ShadImage(
//                     LucideIcons.search,
//                     width: 20,
//                     height: 20,
//                     alignment: Alignment.center,
//                     color: colors.mutedForeground,
//                   ),
//                   onPressed: () {},
//                 ),
//                 const SizedBox(width: 4),
//                 ShadPopover(
//                   controller: _popoverController,
//                   popover: (context) => SizedBox(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ShadButton.ghost(
//                           padding: EdgeInsets.zero,
//                           onPressed: () {
//                             _popoverController.toggle();
//                           },
//                           iconSize: const Size(20, 20),
//                           icon: ShadImage(
//                             LucideIcons.share2,
//                             color: colors.foreground,
//                           ),
//                           child: Text(
//                             'Share',
//                             style: TextStyle(
//                               color: colors.foreground,
//                             ),
//                           ),
//                         ),
//                         ShadButton.ghost(
//                           padding: EdgeInsets.zero,
//                           onPressed: () {
//                             _popoverController.toggle();
//                           },
//                           iconSize: const Size(20, 20),
//                           icon: ShadImage(
//                             LucideIcons.tag,
//                             color: colors.foreground,
//                           ),
//                           child: Text(
//                             'Tags',
//                             style: TextStyle(
//                               color: colors.foreground,
//                             ),
//                           ),
//                         ),
//                         Divider(color: colors.border),
//                         ShadButton.ghost(
//                           padding: EdgeInsets.zero,
//                           onPressed: () {
//                             _popoverController.toggle();
//                           },
//                           iconSize: const Size(20, 20),
//                           icon: ShadImage(
//                             LucideIcons.trash,
//                             color: theme.colorScheme.destructive,
//                           ),
//                           child: Text(
//                             'Delete',
//                             style: theme.textTheme.p.copyWith(
//                               color: theme.colorScheme.destructive,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   child: IconButton(
//                     iconSize: 20,
//                     padding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     style: IconButton.styleFrom(
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     icon: ShadImage(
//                       LucideIcons.ellipsisVertical,
//                       width: 20,
//                       height: 20,
//                       alignment: Alignment.center,
//                       color: colors.mutedForeground,
//                     ),
//                     onPressed: _popoverController.toggle,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// } 