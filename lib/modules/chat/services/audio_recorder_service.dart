import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Platform-specific imports
import 'audio_data_handler.dart' if (dart.library.html) 'audio_data_handler_web.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioDataHandler _audioDataHandler = AudioDataHandler();
  Timer? _timeoutTimer;
  String? _currentRecordingPath;
  bool _isRecorderInitialized = false;
  
  Future<void> initialize() async {
    print('Initializing recorder');
    await _recorder.openRecorder();
    _isRecorderInitialized = true;
    print('Recorder initialized $_isRecorderInitialized');
  }

  Future<bool> hasPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<String> _getRecordingPath() async {
    if (kIsWeb) {
      return 'audio_recording.webm';
    } else {
      final dir = await getTemporaryDirectory();
      return path.join(
        dir.path,
        'audio_recording.wav',
      );
    }
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      await initialize();
    }

    if (await hasPermission()) {
      _currentRecordingPath = await _getRecordingPath();
   
      try {
        await _recorder.startRecorder(
          toFile: _currentRecordingPath,
          codec: kIsWeb ? Codec.opusWebM : Codec.pcm16WAV,
          sampleRate: kIsWeb ? 48000 : 16000,
          numChannels: 1,
        );

        // Start 3-minute timeout
        _timeoutTimer = Timer(const Duration(minutes: 3), () {
          stopRecording();
        });
      } catch (e) {
        print('Error starting recorder: $e');
        if (kIsWeb) {
          try {
            await _recorder.startRecorder(
              toFile: _currentRecordingPath,
              codec: Codec.aacMP4,
              sampleRate: 44100,
              numChannels: 1,
            );
          } catch (e) {
            print('Error with fallback codec: $e');
          }
        }
      }
    }
  }

  Future<List<int>?> stopRecording() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    
    if (_recorder.isRecording) {
      try {
        final path = await _recorder.stopRecorder();
        return await _audioDataHandler.getAudioData(path!);
      } catch (e) {
        print('Error processing audio: $e');
      }
    }
    return null;
  }

  Future<void> dispose() async {
    _timeoutTimer?.cancel();
    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }
  }
} 