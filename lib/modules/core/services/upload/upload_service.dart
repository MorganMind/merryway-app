import 'package:dio/dio.dart';
import 'package:app/modules/core/services/api/i_api_service.dart';
import 'package:app/modules/core/services/upload/i_upload_service.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/services/upload/models/signed_url_response.dart';

class UploadService implements IUploadService {
  final Dio _dio;
  final IApiService _apiService = sl<IApiService>();

  // List of image MIME types
  static const _imageMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/svg+xml',
  };

  UploadService() : _dio = Dio();

  @override
  Future<String> uploadFile({
    required String fileName,
    required String mimeType,
    required List<int> fileData,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Report initial progress for UI feedback
      onProgress?.call(0.0);
      
      final signedUrlResponse = await _getSignedUrl(fileName, mimeType);

      // Create the upload data as a single chunk for better progress tracking
      final data = Stream.value(fileData);

      final response = await _dio.put(
        signedUrlResponse.uploadUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': signedUrlResponse.contentType,
            'Content-Length': fileData.length,
          },
          contentType: signedUrlResponse.contentType,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200) {
        // Ensure we show 100% progress on completion
        onProgress?.call(1.0);
        return signedUrlResponse.blobName;
      }

      throw Exception('Upload failed with status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<SignedUrlResponse> _getSignedUrl(String fileName, String mimeType) async {
    final endpoint = _isImageFile(mimeType) 
        ? '/files/images/upload-url'
        : '/files/upload-url';

    final response = await _apiService.request(
      endpoint: endpoint,
      method: 'POST',
      body: {
        'file_name': fileName,
        'content_type': mimeType,
      },
      fromJson: (json) => SignedUrlResponse.fromJson(json),
    );

    return response;
  }

  bool _isImageFile(String mimeType) {
    return _imageMimeTypes.contains(mimeType.toLowerCase());
  }
} 