// import 'package:app/modules/chat/services/audio_recorder_service.dart';
// import 'package:app/modules/chat/services/transcription_service.dart';
// import 'package:app/modules/core/blocs/layout_bloc.dart';
// import 'package:app/modules/core/blocs/layout_state.dart';
// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:app/modules/core/ui/dialogs/file_upload_dialog.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'dart:io';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:app/modules/chat/widgets/audio_recorder_button.dart';


// class MessageInput extends StatefulWidget {
//   final Function(String) onSend;
//   final String agentName;
//   final String agentId;

//   const MessageInput({
//     Key? key,
//     required this.onSend,
//     required this.agentName,
//     required this.agentId,
//   }) : super(key: key);

//   @override
//   State<MessageInput> createState() => _MessageInputState();
// }

// class _MessageInputState extends State<MessageInput> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   bool _hasText = false;
//   final AudioRecorderService _audioRecorder = AudioRecorderService();
//   final TranscriptionService _transcriptionService = TranscriptionService();
//   bool _isRecording = false;
//   String _transcribedText = '';

//   @override
//   void initState() {
//     super.initState(); 
//     _controller.addListener(_onTextChange);
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_onTextChange);
//     _controller.dispose();
//     _focusNode.dispose();
//     _audioRecorder.dispose();
//     super.dispose();
//   }

//   void _onTextChange() {
//     setState(() {
//       _hasText = _controller.text.isNotEmpty;
//     });
//   }

//   Future<void> _handleMicPress() async {
//     if (!_isRecording) {
//       // Request permission first
//       final hasPermission = await _audioRecorder.hasPermission();
//       if (!hasPermission) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Microphone permission is required to record audio.'),
//             ),
//           );
//         }
//         return;
//       }

//       // Start recording
//       setState(() {
//         _isRecording = true;
//         _transcribedText = '';
//       });

//       await _audioRecorder.startRecording();
//     } else {
//       // Stop recording
//       setState(() {
//         _isRecording = false;
//       });

//       final audioData = await _audioRecorder.stopRecording();
//       if (audioData != null) {
//         try {
//           final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}${kIsWeb ? '.webm' : '.wav'}';
//           final transcriptionStream = await _transcriptionService
//               .transcribeAudio(audioData, fileName);

//           await for (final text in transcriptionStream) {
//             if (text.isNotEmpty) {
//               setState(() {
//                 _transcribedText = text;
//                 _controller.text = _transcribedText.trim();
//                 _hasText = true;
//               });
//             }
//           }
//         } catch (e) {
//           print('Transcription error: $e');
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to transcribe audio. Please try again.'),
//               ),
//             );
//           }
//         }
//       }
//     }
//   }

//   void _handleSubmit() {
//     final text = _controller.text.trim();
//     if (text.isNotEmpty) {
//       widget.onSend(text);
//       _controller.clear();
//       setState(() {
//         _hasText = false;
//         _transcribedText = '';
//       });
//     }
//   }

//   void _handleFileUpload() {
//     showFileUploadDialog(context, widget.agentId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;
    
//     return BlocBuilder<LayoutBloc, LayoutState>(
//       builder: (context, layoutState) {
//         final isMobile = layoutState.layoutType == LayoutType.mobile;
        
//         return Container(
//           constraints: isMobile 
//             ? const BoxConstraints(
//               minHeight: 40, 
//               maxHeight: 300, // Approximately 8 lines + padding
//             ) : const BoxConstraints(
//               minHeight: 72, 
//               maxHeight: 300, // Approximately 8 lines + padding
//             ),
//           padding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: colors.background,
//             borderRadius: isMobile ? BorderRadius.circular(28) : BorderRadius.circular(12),
//             border: Border.all(color: colors.border),
//             boxShadow: isMobile ? null : [
//               BoxShadow(
//                 color: colors.foreground.withOpacity(0.1),
//                 blurRadius: 2,
//                 offset: const Offset(0, 1),
//                 spreadRadius: -1,
//               ),
//               BoxShadow(
//                 color: colors.foreground.withOpacity(0.1),
//                 blurRadius: 3,
//                 offset: const Offset(0, 1),
//                 spreadRadius: 0,
//               ),
//             ],
//           ),
//           child: isMobile ? Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // File plus icon
//               SizedBox(
//                 width: 30,  // Constrain button width
//                 height: 30, // Constrain button height
//                 child: IconButton(
//                   iconSize: 20,
//                   padding: EdgeInsets.only(left: 10),
//                   visualDensity: VisualDensity.compact,
//                   style: IconButton.styleFrom(
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   icon: const ShadImage(
//                     LucideIcons.filePlus,
//                     width: 20,
//                     height: 20,
//                     alignment: Alignment.center,
//                   ),
//                   onPressed: _handleFileUpload,
//                 ),
//               ),
              
//               // Text field
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: TextField(
//                     controller: _controller,
//                     focusNode: _focusNode,
//                     maxLines: null,
//                     textAlignVertical: TextAlignVertical.center,
//                     decoration: InputDecoration(
//                       hintText: 'Message ${widget.agentName}...',
//                       hintStyle: theme.textTheme.muted,
//                       border: InputBorder.none,
//                       isDense: true,
//                       contentPadding: EdgeInsets.only(bottom: 4),
//                     ),
//                     style: theme.textTheme.p.copyWith(
//                       color: colors.foreground,
//                     ),
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed 
//                       ? TextInputAction.newline 
//                       : TextInputAction.send,
//                     onChanged: (value) {
//                       setState(() {
//                         _hasText = value.isNotEmpty;
//                       });
//                     },
//                   ),
//                 ),
//               ),

//               // Send/Mic button
//               SizedBox(
//                 width: 30,  // Constrain button width
//                 height: 30, // Constrain button height
//                 child: _hasText 
//                   ? IconButton(
//                       iconSize: 20,
//                       padding: EdgeInsets.zero,
//                       style: IconButton.styleFrom(
//                         shape: const CircleBorder(),
//                         padding: EdgeInsets.zero,
//                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       ),
//                       icon: const ShadImage(
//                         LucideIcons.sendHorizontal,
//                         width: 20,
//                         height: 20,
//                         color: Color(0xFFA1A1AA),
//                         alignment: Alignment.center,
//                       ),
//                       onPressed: _handleSubmit,
//                     )
//                   : AudioRecorderButton(
//                       onTranscriptionComplete: (text) {
//                         setState(() {
//                           _controller.text = text;
//                           _hasText = true;
//                         });
//                       },
//                     ),
//               ),
//               SizedBox(width: 8), // Add some padding at the end
//             ], 
//           ) : Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Desktop layout - existing code
//               Flexible(
//                 child: KeyboardListener(
//                   focusNode: FocusNode(),
//                   onKeyEvent: (event) {
//                     if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
//                       if (HardwareKeyboard.instance.isControlPressed || 
//                           HardwareKeyboard.instance.isMetaPressed) {
//                         final text = _controller.text;
//                         final selection = _controller.selection;
//                         final newText = text.replaceRange(
//                           selection.start,
//                           selection.end,
//                           '\n',
//                         );
//                         _controller.value = TextEditingValue(
//                           text: newText,
//                           selection: TextSelection.collapsed(
//                             offset: selection.start + 1,
//                           ),
//                         );
//                       } else {
//                         _handleSubmit();
//                       }
//                     }
//                   },
//                   child: TextField(
//                     controller: _controller,
//                     focusNode: _focusNode,
//                     maxLines: null,
//                     decoration: InputDecoration(
//                       hintText: 'Message ${widget.agentName}...',
//                       hintStyle: theme.textTheme.muted,
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     style: theme.textTheme.p.copyWith(
//                       color: colors.foreground,
//                     ),
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed 
//                       ? TextInputAction.newline 
//                       : TextInputAction.send,
//                     onChanged: (value) {
//                       setState(() {
//                         _hasText = value.isNotEmpty;
//                       });
//                     },
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 4),

//               // Bottom row with actions
//               Row(
//                 children: [
//                   IconButton(
//                     iconSize: 20,
//                     padding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     style: IconButton.styleFrom(
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     icon: const ShadImage(
//                       LucideIcons.filePlus,
//                       width: 20,
//                       height: 20,
//                       alignment: Alignment.center,
//                     ),
//                     onPressed: _handleFileUpload,
//                   ),
//                   IconButton(
//                     iconSize: 20,
//                     padding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     style: IconButton.styleFrom(
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     icon: const ShadImage(
//                       LucideIcons.globe,
//                       width: 20,
//                       height: 20,
//                       alignment: Alignment.center,
//                     ),
//                     onPressed: () {},
//                   ),
//                   IconButton(
//                     iconSize: 20,
//                     padding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     style: IconButton.styleFrom(
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     icon: const ShadImage(
//                       LucideIcons.calendar,
//                       width: 20,
//                       height: 20,
//                       alignment: Alignment.center,
//                     ),
//                     onPressed: () {},
//                   ),

//                   const Spacer(),

//                   _hasText 
//                     ? IconButton(
//                         iconSize: 20,
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shape: const CircleBorder(),
//                           padding: const EdgeInsets.all(8),
//                         ),
//                         icon: const ShadImage(
//                           LucideIcons.sendHorizontal,
//                           width: 20,
//                           height: 20,
//                           color: Color(0xFFA1A1AA),
//                           alignment: Alignment.center,
//                         ),
//                         onPressed: _handleSubmit,
//                       )
//                     : AudioRecorderButton(
//                         onTranscriptionComplete: (text) {
//                           setState(() {
//                             _controller.text = text;
//                             _hasText = true;
//                           }); 
//                         },
//                         showBackground: true,
//                         padding: const EdgeInsets.all(8),
//                       ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// } 