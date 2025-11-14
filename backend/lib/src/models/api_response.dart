/// Standard API response wrapper for consistent response format
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
  });

  /// Convert response to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
    };
  }

  /// Factory method for success response
  factory ApiResponse.success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Factory method for error response
  factory ApiResponse.error({
    required String message,
    dynamic data,
    int statusCode = 400,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }
}
