import 'dart:io';

class AudioDataHandler {
  Future<List<int>?> getAudioData(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      await file.delete(); // Clean up
      return bytes;
    }
    return null;
  }
} 