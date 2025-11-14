import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'middleware/cors_middleware.dart';
import 'routes/auth_routes.dart';
import 'routes/course_routes.dart';
import 'routes/enrollment_routes.dart';
import 'utils/response_helper.dart';

/// Main application router and middleware configuration
class App {
  /// Create and configure the application handler
  Handler createHandler() {
    final router = Router();

    // API routes
    router.mount('/api/auth', authRoutes());
    router.mount('/api/courses', courseRoutes());
    router.mount('/api/enrollments', enrollmentRoutes());

    // Health check endpoint
    router.get('/health', (Request request) {
      return ResponseHelper.success(
        message: 'Server is healthy',
        data: {
          'status': 'ok',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    });

    // Welcome endpoint
    router.get('/', (Request request) {
      return ResponseHelper.success(
        message: 'Welcome to Student Registration System API',
        data: {
          'version': '1.0.0',
          'endpoints': {
            'auth': '/api/auth',
            'courses': '/api/courses',
            'enrollments': '/api/enrollments',
          },
        },
      );
    });

    // 404 handler
    router.all('/<ignored|.*>', (Request request) {
      return ResponseHelper.notFound(
        message: 'Route not found: ${request.method} ${request.url.path}',
      );
    });

    // Create pipeline with middleware
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsMiddleware())
        .addHandler(router);

    return handler;
  }
}
