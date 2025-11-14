import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/enrollment_controller.dart';
import '../middleware/auth_middleware.dart';

/// Enrollment routes configuration
Router enrollmentRoutes() {
  final router = Router();
  final controller = EnrollmentController();

  // All enrollment routes require authentication
  router.get('/my-courses',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getStudentCourses));

  router.get('/active',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getActiveEnrollments));

  router.get('/grades',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getStudentGrades));

  router.post('/<courseId>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler((Request request) {
            final courseId = request.params['courseId']!;
            return controller.enrollInCourse(request, courseId);
          }));

  router.delete('/<courseId>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler((Request request) {
            final courseId = request.params['courseId']!;
            return controller.dropCourse(request, courseId);
          }));

  router.put('/<enrollmentId>/re-enroll',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler((Request request) {
            final enrollmentId = request.params['enrollmentId']!;
            return controller.reEnrollCourse(request, enrollmentId);
          }));

  return router;
}
