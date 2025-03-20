abstract class IUploadService {
  Future<String> uploadFile({
    required String fileName,
    required String mimeType,
    required List<int> fileData,
    void Function(double progress)? onProgress,
  });
} 