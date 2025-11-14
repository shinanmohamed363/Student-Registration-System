import 'package:shelf/shelf.dart';

/// CORS middleware to handle Cross-Origin Resource Sharing
/// Allows Flutter app to communicate with the API from different origins
Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Handle preflight OPTIONS requests
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
          'Access-Control-Max-Age': '86400',
        });
      }

      // Process the request
      final response = await handler(request);

      // Add CORS headers to response
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      });
    };
  };
}
