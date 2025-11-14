import 'package:shelf/shelf.dart';
import '../utils/jwt_helper.dart';
import '../utils/response_helper.dart';

/// Authentication middleware to protect routes that require authentication
/// Verifies JWT token and adds student information to request context
Middleware authMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Extract token from Authorization header
      final authHeader = request.headers['authorization'];
      final token = JwtHelper.extractToken(authHeader);

      if (token == null) {
        return ResponseHelper.unauthorized(
          message: 'No token provided',
        );
      }

      // Verify token
      final payload = JwtHelper.verifyToken(token);
      if (payload == null) {
        return ResponseHelper.unauthorized(
          message: 'Invalid or expired token',
        );
      }

      // Add student info to request context
      final updatedRequest = request.change(context: {
        'studentId': payload['studentId'],
        'email': payload['email'],
      });

      return handler(updatedRequest);
    };
  };
}

/// Extract student ID from authenticated request
int? getStudentIdFromRequest(Request request) {
  return request.context['studentId'] as int?;
}

/// Extract email from authenticated request
String? getEmailFromRequest(Request request) {
  return request.context['email'] as String?;
}
