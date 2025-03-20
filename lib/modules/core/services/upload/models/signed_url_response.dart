class SignedUrlResponse {
  final String uploadUrl;
  final String blobName;
  final String fileType;
  final String contentType;

  SignedUrlResponse({
    required this.uploadUrl,
    required this.blobName,
    required this.fileType,
    required this.contentType,
  });

  factory SignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return SignedUrlResponse(
      uploadUrl: json['upload_url'] as String,
      blobName: json['blob_name'] as String,
      fileType: json['file_type'] as String,
      contentType: json['content_type'] as String,
    );
  }
} 