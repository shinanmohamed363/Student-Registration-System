import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/app_config.dart';

/// Helper class for JWT token generation and verification
class JwtHelper {
  static final _config = AppConfig();

  /// Generate JWT token for a student
  static String generateToken(int studentId, String email) {
    final jwt = JWT(
      {
        'studentId': studentId,
        'email': email,
        'iat': DateTime.now().millisecondsSinceEpoch,
        'exp': DateTime.now()
            .add(Duration(hours: _config.jwtExpiryHours))
            .millisecondsSinceEpoch,
      },
    );

    return jwt.sign(SecretKey(_config.jwtSecret));
  }

  /// Verify JWT token and return payload
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_config.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;

      // Check if token is expired
      final exp = payload['exp'] as int;
      if (DateTime.now().millisecondsSinceEpoch > exp) {
        return null;
      }

      return payload;
    } catch (e) {
      print('JWT verification failed: $e');
      return null;
    }
  }

  /// Extract token from Authorization header
  static String? extractToken(String? authHeader) {
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.substring(7);
  }

  /// Get student ID from token
  static int? getStudentIdFromToken(String token) {
    final payload = verifyToken(token);
    return payload?['studentId'] as int?;
  }
}
