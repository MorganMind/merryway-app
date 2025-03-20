import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sse_service_interface.dart';
import 'sse_stream.dart' if (dart.library.js) 'sse_stream_web.dart';

class SSEService implements SSEServiceInterface {
  @override
  Stream<String> connectToSSE({
    required String url,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async* {
    final request = http.Request(method, Uri.parse(url));
    
    // Set default headers
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';
    
    // Add custom headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add body if present
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(body);
    }

    final stream = await getStream(request);
    await for (var chunk in stream.transform(utf8.decoder)) {
      if (chunk.isNotEmpty) {
        // Split by 'data: ' to handle multiple messages in one chunk
        final messages = chunk.split('data: ')
            .where((msg) => msg.isNotEmpty) // Filter out empty messages
            .map((msg) => msg.replaceAll(RegExp(r'\n\n$'), '')); // Remove exactly two trailing newlines
            
        for (var message in messages) {
          if (message.isNotEmpty) {
            yield message;
          }
        }
      }
    }
  }
}