import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/validation_middleware.dart';

/// Authentication routes configuration
Router authRoutes() {
  final router = Router();
  final controller = AuthController();

  // Public routes
  router.post('/register',
      Pipeline()
          .addMiddleware(ValidationMiddleware.requireJsonBody())
          .addHandler(controller.register));

  router.post('/login',
      Pipeline()
          .addMiddleware(ValidationMiddleware.requireJsonBody())
          .addHandler(controller.login));

  // Protected routes (require authentication)
  router.get('/profile',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(controller.getProfile));

  router.put('/profile',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(ValidationMiddleware.requireJsonBody())
          .addHandler(controller.updateProfile));

  router.post('/change-password',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(ValidationMiddleware.requireJsonBody())
          .addHandler(controller.changePassword));

  return router;
}
