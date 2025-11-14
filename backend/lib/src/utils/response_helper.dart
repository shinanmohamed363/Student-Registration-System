import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/api_response.dart';

/// Helper class for creating HTTP responses
class ResponseHelper {
  /// Create a JSON response
  static Response json(
    dynamic data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: defaultHeaders,
    );
  }

  /// Create a success response
  static Response success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    final response = ApiResponse.success(
      message: message,
      data: data,
      statusCode: statusCode,
    );
    return json(response.toJson(), statusCode: statusCode);
  }

  /// Create an error response
  static Response error({
    required String message,
    dynamic data,
    int statusCode = 400,
  }) {
    final response = ApiResponse.error(
      message: message,
      data: data,
      statusCode: statusCode,
    );
    return json(response.toJson(), statusCode: statusCode);
  }

  /// Create a not found response
  static Response notFound({String message = 'Resource not found'}) {
    return error(message: message, statusCode: 404);
  }

  /// Create an unauthorized response
  static Response unauthorized({String message = 'Unauthorized'}) {
    return error(message: message, statusCode: 401);
  }

  /// Create a forbidden response
  static Response forbidden({String message = 'Forbidden'}) {
    return error(message: message, statusCode: 403);
  }

  /// Create an internal server error response
  static Response internalServerError({
    String message = 'Internal server error',
  }) {
    return error(message: message, statusCode: 500);
  }

  /// Create a validation error response
  static Response validationError({
    required String message,
    dynamic errors,
  }) {
    return error(
      message: message,
      data: errors,
      statusCode: 422,
    );
  }
}
