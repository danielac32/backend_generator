import 'package:shelf/shelf.dart';

Middleware usersMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Ejemplo: Validación de headers
      if (request.headers['content-type'] != 'application/json') {
        return Response.badRequest(
          body: 'Content-Type must be application/json',
        );
      }

      // Ejemplo: Logging
      print('Users Middleware: ${request.method} ${request.url.path}');

      return await innerHandler(request);
    };
  };
}
