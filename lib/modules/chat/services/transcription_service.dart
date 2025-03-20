import 'package:app/modules/core/services/api/i_api_service.dart';
import 'package:app/modules/core/di/service_locator.dart';

class TranscriptionService {
  final _apiService = sl<IApiService>();
  
  Future<Stream<String>> transcribeAudio(List<int> audioData, String filename) async {
    return _apiService.streamMultipartRequest(
      endpoint: '/transcribe/',
      fileBytes: audioData,
      fileName: filename,
      fileField: 'audio',
      contentType: 'audio/wav',
    );
  }
} 