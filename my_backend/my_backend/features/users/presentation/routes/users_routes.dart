import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/users_controller.dart';
import '../middlewares/users_middleware.dart';

Router usersRoutes(UsersController controller) {
  final router = Router();
  final middleware = usersMiddleware();

  router.get('/', (Request request) {
    return middleware(controller.getAll)(request);
  });

  router.get('/<id>', (Request request, String id) {
    return middleware(controller.getById)(request..params['id'] = id);
  });

  return router;
}
