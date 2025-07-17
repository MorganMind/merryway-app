import 'package:http/http.dart' as http;

class AudioDataHandler {
  Future<List<int>?> getAudioData(String path) async {
    try {
      // For web, the path is already a blob URL
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to fetch audio data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio data: $e');
    }
    return null;
  }
} 