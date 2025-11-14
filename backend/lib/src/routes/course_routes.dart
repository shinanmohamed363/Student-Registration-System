import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/course_controller.dart';
import '../middleware/auth_middleware.dart';

/// Course routes configuration
Router courseRoutes() {
  final router = Router();
  final controller = CourseController();

  // All course routes require authentication
  router.get('/',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getAllCourses));

  router.get('/available',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getAvailableCourses));

  router.get('/search',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.searchCourses));

  router.get('/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler((Request request) {
            final id = request.params['id']!;
            return controller.getCourseById(request, id);
          }));

  router.get('/<id>/assignments',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler((Request request) {
            final id = request.params['id']!;
            return controller.getCourseAssignments(request, id);
          }));

  return router;
}
