import 'dart:convert';

class InviteCodeUtils {
  static String generateInviteCode(String organizationId, String userId) {
    // Combine the IDs with a delimiter
    final combined = '$organizationId:$userId';
    
    // Convert to base64 and make it URL safe
    final encoded = base64Url.encode(utf8.encode(combined));
    
    // Trim any padding characters
    return encoded.replaceAll('=', '');
  }

  static (String, String)? decodeInviteCode(String code) {
    try {
      // Add back padding if needed
      final padding = (4 - (code.length % 4)) % 4;
      final paddedCode = code + ('=' * padding);
      
      // Decode from base64
      final decoded = utf8.decode(base64Url.decode(paddedCode));
      
      // Split back into IDs
      final parts = decoded.split(':');
      if (parts.length == 2) {
        return (parts[0], parts[1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 