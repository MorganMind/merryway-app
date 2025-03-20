abstract class SSEServiceInterface {
  Stream<String> connectToSSE({
    required String url,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });
}