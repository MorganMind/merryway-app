import 'dart:convert';
import 'package:app/config/environment.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/services/sse/sse_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/modules/core/services/api/i_api_service.dart';


class ApiService implements IApiService {
  final String baseUrl = Environment.apiUrl;
  final SupabaseClient _supabase = sl<SupabaseClient>();

  Map<String, String> get _defaultHeaders => {
    'Authorization': 'Bearer ${_getValidToken()}',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache',
  };

  Map<String, String> get _defaultPublicHeaders => {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache',
  };

  String _getValidToken() {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw ApiException(message: 'No active session');
    }
   
    // Check if token is expired or about to expire (within 60 seconds)
    if (session.isExpired) {
      // This will automatically refresh the token if needed
      _supabase.auth.refreshSession(); 
    }

    return session.accessToken;
  }

  @override
  Future<T> request<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    bool isPublic = false,
  }) async {
    final baseUri = Uri.parse(baseUrl);

    final uri = baseUri.replace(
      path: '${baseUri.path}/${endpoint.replaceAll(RegExp(r'^/'), '')}/',
      queryParameters: queryParameters,
    );
    print('URI: $uri IS PUBLIC: $isPublic');
  
    final headers = isPublic 
      ? {..._defaultPublicHeaders, ...?additionalHeaders} 
      : {..._defaultHeaders, ...?additionalHeaders};
    
    http.Response response;
    
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  @override
  Stream<String> streamRequest({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) {
    final baseUri = Uri.parse(baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/${endpoint.replaceAll(RegExp(r'^/'), '')}/',
    );
   
    final headers = {
      ..._defaultHeaders, 
      'Accept': 'text/event-stream',
      ...?additionalHeaders
      };

    try {
      final request = http.Request(method, uri)
        ..headers.addAll(headers);

      if (body != null) {
        request.body = json.encode(body);
      }

      return sl<SSEService>().connectToSSE(
          url: uri.toString(),
          method: method,
          headers: headers,
          body: body,
        );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<Stream<String>> streamMultipartRequest({
    required String endpoint,
    required List<int> fileBytes,
    required String fileName,
    String fileField = 'audio',
    String contentType = 'audio/wav',
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('${Environment.apiUrl}$endpoint');
    
    final headers = {
      ..._defaultHeaders, 
      'Accept': 'text/event-stream',
      ...?additionalHeaders
      };
    
    // Prepare the multipart request
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName,
          contentType: MediaType(
            contentType.split('/')[0],
            contentType.split('/')[1],
          ),
        ),
      );

    // Send the request
    final response = await request.send();
    
    if (response.statusCode != 200) {
      throw ApiException(statusCode: response.statusCode, message: 'Failed to upload file');
    }

    // Transform the response stream to handle SSE
    return response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.startsWith('data: '))
        .map((line) {
          final jsonStr = line.substring(6); // Remove 'data: ' prefix
          final data = json.decode(jsonStr);
          return data['text'] as String;
        });
  }

}

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() => 
    'ApiException: ${statusCode != null ? '[$statusCode] ' : ''}$message';
} 