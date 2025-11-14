import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import '../lib/src/config/app_config.dart';
import '../lib/src/config/database.dart';
import '../lib/src/app.dart';

/// Main server entry point
void main() async {
  // Initialize configuration
  final config = AppConfig();
  config.init();

  print('🚀 Starting Student Registration System API...');
  print('📝 Environment: ${config.dbName}');

  // Test database connection
  try {
    final db = Database.instance;
    await db.getConnection();
    print('✅ Database connected successfully');
  } catch (e) {
    print('❌ Failed to connect to database: $e');
    print('Please ensure MariaDB is running and credentials are correct in .env file');
    exit(1);
  }

  // Create application handler
  final app = App();
  final handler = app.createHandler();

  // Start server
  final server = await io.serve(
    handler,
    config.serverHost,
    config.serverPort,
  );

  print('✨ Server started successfully!');
  print('🌐 Server running at: http://${server.address.host}:${server.port}');
  print('📚 API Base URL: http://${server.address.host}:${server.port}/api');
  print('');
  print('Available endpoints:');
  print('  POST   /api/auth/register        - Register new student');
  print('  POST   /api/auth/login           - Student login');
  print('  GET    /api/auth/profile         - Get student profile');
  print('  PUT    /api/auth/profile         - Update student profile');
  print('  POST   /api/auth/change-password - Change password');
  print('  GET    /api/courses              - Get all courses');
  print('  GET    /api/courses/available    - Get available courses');
  print('  GET    /api/courses/<id>         - Get course details');
  print('  GET    /api/enrollments/my-courses - Get enrolled courses');
  print('  POST   /api/enrollments/<courseId> - Enroll in course');
  print('  GET    /api/enrollments/grades   - Get grades and assignments');
  print('');
  print('Press Ctrl+C to stop the server');
}
