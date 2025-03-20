// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:app/modules/core/blocs/layout_bloc.dart';
// import 'package:app/modules/core/blocs/layout_state.dart';
// import 'package:app/modules/core/di/service_locator.dart';
// import 'package:app/modules/core/services/upload/i_upload_service.dart';
// import 'package:app/modules/core/ui/widgets/file_upload_card.dart';
// import 'package:app/modules/content/blocs/content_bloc.dart';
// import 'package:app/modules/content/blocs/content_event.dart';
// import 'package:app/modules/content/models/create_source_dto.dart';

// void showFileUploadDialog(BuildContext context, [String? agentId]) {
//   final layoutType = sl<LayoutBloc>().state.layoutType;
//   final uploadService = sl<IUploadService>();
//   final contentBloc = sl<ContentBloc>();
  
//   if (layoutType != LayoutType.mobile) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         double? uploadProgress;
        
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               backgroundColor: Colors.transparent,
//               child: FileUploadCard(
//                 uploadProgress: uploadProgress,
//                 onFileSelected: (fileName, mimeType, fileData) async {
//                   try {
//                     final blobName = await uploadService.uploadFile(
//                       fileName: fileName,
//                       mimeType: mimeType,
//                       fileData: fileData,
//                       onProgress: (progress) {
//                         setState(() => uploadProgress = progress);
//                       },
//                     );

//                     final createReferenceDto = CreateSourceDto(
//                       name: fileName,
//                       fileType: mimeType,
//                       fileUrl: blobName,
//                     );

//                     contentBloc.add(CreateSourceRequested(createReferenceDto));

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Upload complete')),
//                     );
                    
//                     Navigator.pop(context);
                    
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Upload failed: $e')),
//                     );
//                   }
//                 },
//               ),
//             );
//           }
//         );
//       },
//     );
//   } else {
//     // Mobile: Show sliding sheet
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.zero,
//         ),
//       ),
//       isScrollControlled: true,
//       useRootNavigator: true,
//       builder: (dialogContext) {
//         double? uploadProgress;
        
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               height: MediaQuery.of(context).size.height,
//               color: Colors.white,
//               child: FileUploadCard(
//                 showCardDecoration: false,
//                 uploadProgress: uploadProgress,
//                 onFileSelected: (fileName, mimeType, fileData) async {
//                   try {
//                     final url = await uploadService.uploadFile(
//                       fileName: fileName,
//                       mimeType: mimeType,
//                       fileData: fileData,
//                       onProgress: (progress) {
//                         setState(() => uploadProgress = progress);
//                       },
//                     );

//                     final createReferenceDto = CreateSourceDto(
//                       name: fileName,
//                       fileType: mimeType,
//                       fileUrl: url,
//                     );

//                     contentBloc.add(CreateSourceRequested(createReferenceDto));

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Upload complete')),
//                     );
                    
//                     Navigator.pop(context);
                    
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Upload failed: $e')),
//                     );
//                   }
//                 },
//               ),
//             );
//           }
//         );
//       },
//     );
//   }
// } 