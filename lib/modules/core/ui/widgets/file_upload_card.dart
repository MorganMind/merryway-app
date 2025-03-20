import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';

/// List of allowed video and audio file extensions based on FFmpeg supported formats
final _allowedExtensions = [
  // Video formats
  'mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'm4v', 'mpg', 'mpeg', 'wmv', '3gp',
  // Audio formats
  'mp3', 'wav', 'aac', 'ogg', 'm4a', 'wma', 'flac', 'aiff', 'alac',
];

class FileUploadCard extends StatefulWidget {
  final bool showCardDecoration;
  final Function(String fileName, String mimeType, List<int> fileData)? onFileSelected;
  final double? uploadProgress;
  final double? width;
  final double? height;


  const FileUploadCard({
    super.key,
    this.showCardDecoration = true,
    this.onFileSelected,
    this.uploadProgress,
    this.width = 415,
    this.height = 295,
  });

  @override
  State<FileUploadCard> createState() => _FileUploadCardState();
}

class _FileUploadCardState extends State<FileUploadCard> {
  bool _isDragging = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = file.extension?.toLowerCase();
        
        if (ext != null && _allowedExtensions.contains(ext)) {
          if (file.bytes != null && widget.onFileSelected != null) {
            widget.onFileSelected!(
              file.name,
              _getMimeType(file.extension ?? ''),
              file.bytes!,
            );
          }
        } else {
          // Show error for unsupported format
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a supported video or audio file format'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      // Video formats
      case 'mp4':
        return 'video/mp4';
      case 'mkv':
        return 'video/x-matroska';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'flv':
        return 'video/x-flv';
      case 'm4v':
        return 'video/x-m4v';
      case 'mpg':
      case 'mpeg':
        return 'video/mpeg';
      case 'wmv':
        return 'video/x-ms-wmv';
      case '3gp':
        return 'video/3gpp';
        
      // Audio formats
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';
      case 'wma':
        return 'audio/x-ms-wma';
      case 'flac':
        return 'audio/flac';
      case 'aiff':
        return 'audio/x-aiff';
      case 'alac':
        return 'audio/x-alac';
        
      // Default
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _handleDrop(List<XFile> files) async {
    if (files.isNotEmpty && widget.onFileSelected != null) {
      final file = files.first;
      final bytes = await file.readAsBytes();
      widget.onFileSelected!(
        file.name,
        file.mimeType ?? _getMimeType(file.name.split('.').last),
        bytes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = context.appTheme;
    final isUploading = widget.uploadProgress != null && widget.uploadProgress! < 1.0;
    
    return ShadCard(
      border: widget.showCardDecoration 
          ? null 
          : Border.all(color: Colors.transparent, width: 0),
      shadows: widget.showCardDecoration ? null : [],
      child: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Container(
            //   padding: const EdgeInsets.all(0),
            //   decoration: BoxDecoration(
            //     border: Border(
            //       bottom: BorderSide(
            //         color: colors.border,
            //         width: 1,
            //       ),

            //     ),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Upload file',
            //         style: theme.textTheme.h2.copyWith(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         'Choose a file from your computer',
            //         style: theme.textTheme.muted,
            //       ), 
            //       const SizedBox(height: 24),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 24),
             _buildUploadArea(isUploading, colors),
            if (isUploading) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: 415, 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: widget.uploadProgress,
                    backgroundColor: const Color(0xFFF4F4F5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    minHeight: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(bool isUploading, AppThemeExtension colors) {
    final uploadArea = Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.cloudUpload,
            size: 48,
            color: colors.border,
          ),
          const SizedBox(height: 16),
          Text(
            'Videos, images and documents are supported',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.border,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ShadButton.outline(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: isUploading ? null : _pickFile,
            child: const Text('Browse files'),
          ),
        ],
      ),
    );

    if (kIsWeb) {
      return DropTarget(
        onDragDone: (detail) => _handleDrop(detail.files),
        onDragEntered: (detail) => setState(() => _isDragging = true),
        onDragExited: (detail) => setState(() => _isDragging = false),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          color: _isDragging ? Colors.black : const Color(0xFFE4E4E7),
          strokeWidth: 1,
          dashPattern: const [6, 4],
          child: uploadArea,
        ),
      );
    } else {
      return DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        color: const Color(0xFFE4E4E7),
        strokeWidth: 1,
        dashPattern: const [6, 4],
        child: uploadArea,
      );
    }
  }
} 