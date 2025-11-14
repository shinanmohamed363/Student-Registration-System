import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../utils/response_helper.dart';

/// Validation middleware for request body validation
class ValidationMiddleware {
  /// Validate that request has a JSON body
  static Middleware requireJsonBody() {
    return (Handler handler) {
      return (Request request) async {
        final contentType = request.headers['content-type'];

        if (contentType == null || !contentType.contains('application/json')) {
          return ResponseHelper.validationError(
            message: 'Content-Type must be application/json',
          );
        }

        try {
          final body = await request.readAsString();
          if (body.isEmpty) {
            return ResponseHelper.validationError(
              message: 'Request body cannot be empty',
            );
          }

          // Try to parse JSON to validate it
          jsonDecode(body);

          // Create new request with parsed body in context
          final updatedRequest = request.change(context: {
            ...request.context,
            'body': body,
          });

          return handler(updatedRequest);
        } catch (e) {
          return ResponseHelper.validationError(
            message: 'Invalid JSON in request body',
          );
        }
      };
    };
  }

  /// Validate required fields in request body
  static bool validateRequiredFields(
    Map<String, dynamic> body,
    List<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      if (!body.containsKey(field) || body[field] == null || body[field].toString().trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Get missing required fields
  static List<String> getMissingFields(
    Map<String, dynamic> body,
    List<String> requiredFields,
  ) {
    final missing = <String>[];
    for (final field in requiredFields) {
      if (!body.containsKey(field) || body[field] == null || body[field].toString().trim().isEmpty) {
        missing.add(field);
      }
    }
    return missing;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate student ID format (alphanumeric, 6-20 characters)
  static bool isValidStudentId(String studentId) {
    final studentIdRegex = RegExp(r'^[A-Z0-9]{3,20}$');
    return studentIdRegex.hasMatch(studentId);
  }

  /// Validate phone number format
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    return phoneRegex.hasMatch(phone);
  }
}
