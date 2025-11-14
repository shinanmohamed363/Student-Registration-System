import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../utils/storage_helper.dart';

/// API client for making HTTP requests
/// Handles authentication, headers, and error responses
class ApiClient {
  final http.Client _client;
  final StorageHelper _storage;

  ApiClient({http.Client? client, StorageHelper? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? StorageHelper();

  /// Get authorization header with token
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle API response and extract data
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      body = {'message': response.body};
    }

    // Handle successful responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    // Handle error responses
    final message = body['message'] ?? 'An error occurred';

    if (statusCode == 401) {
      throw AuthFailure(message);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ValidationFailure(message);
    } else if (statusCode >= 500) {
      throw ServerFailure(message);
    }

    throw ServerFailure('Unexpected error occurred');
  }

  /// Make GET request
  Future<dynamic> get(
    String url, {
    bool requiresAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      // Build URL with query parameters
      var uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } on http.ClientException {
      throw NetworkFailure('Network error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Make POST request
  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } on http.ClientException {
      throw NetworkFailure('Network error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Make PUT request
  Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } on http.ClientException {
      throw NetworkFailure('Network error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Make DELETE request
  Future<dynamic> delete(
    String url, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } on http.ClientException {
      throw NetworkFailure('Network error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
