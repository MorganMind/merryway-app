import 'package:app/modules/transcriptions/services/audio_recorder_service.dart';
import 'package:app/modules/transcriptions/services/transcription_service.dart';
import 'package:app/modules/core/theme/theme_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AudioRecorderButton extends StatefulWidget {
  final Function(String) onTranscriptionComplete;
  final bool showBackground;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const AudioRecorderButton({
    super.key,
    required this.onTranscriptionComplete,
    this.showBackground = true,
    this.iconSize,
    this.padding,
  });

  @override
  State<AudioRecorderButton> createState() => _AudioRecorderButtonState();
}

class _AudioRecorderButtonState extends State<AudioRecorderButton> {
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  final TranscriptionService _transcriptionService = TranscriptionService();
  bool _isRecording = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _handleMicPress() async {
    if (!_isRecording) {
      // Request permission first
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record audio.'),
            ),
          );
        }
        return;
      }

      // Start recording
      setState(() => _isRecording = true);
      await _audioRecorder.startRecording();
    } else {
      // Stop recording
      setState(() => _isRecording = false);

      final audioData = await _audioRecorder.stopRecording();
      if (audioData != null) {
        try {
          final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}${kIsWeb ? '.webm' : '.wav'}';
          final transcriptionStream = await _transcriptionService
              .transcribeAudio(audioData, fileName);

          await for (final text in transcriptionStream) {
            if (text.isNotEmpty) {
              widget.onTranscriptionComplete(text.trim());
              break; // Exit after first valid transcription
            }
          }
        } catch (e) {
          print('Transcription error: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to transcribe audio. Please try again.'),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;

    return IconButton(
      iconSize: widget.iconSize ?? 20,
      padding: widget.padding ?? EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: widget.showBackground && !_isRecording 
          ? colors.gold
          : Colors.transparent,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: ShadImage(
        _isRecording ? LucideIcons.square : LucideIcons.mic,
        width: widget.iconSize ?? 20,
        height: widget.iconSize ?? 20,
        color: widget.showBackground && !_isRecording 
          ? colors.black 
          : colors.mutedForeground,
        alignment: Alignment.center,
      ),
      onPressed: _handleMicPress,
    );
  }
} 