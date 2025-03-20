abstract class IApiService {
  Future<T> request<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    bool isPublic = false,
  });

  Stream<String> streamRequest({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  });

  Future<Stream<String>> streamMultipartRequest({
    required String endpoint,
    required List<int> fileBytes,
    required String fileName,
    String fileField = 'audio',
    String contentType = 'audio/wav',
  });
} 