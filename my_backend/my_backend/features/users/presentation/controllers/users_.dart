import 'package:shelf/shelf.dart';
import '../../services/users_service.dart';
import '../../domain/entities/users_entity.dart';
import '../../shared/utils/api_response.dart';

class UsersController {
  final UsersService _service;

  UsersController(this._service);

  Future<Response> getAll(Request request) async {
    try {
      final items = await _service.getAllUserss();
      return Response.ok(ApiResponse.success(items).toJson());
    } catch (e) {
      return Response.internalServerError(
        body: ApiResponse.error('Error al obtener userss').toJson(),
      );
    }
  }

  Future<Response> getById(Request request, String id) async {
    try {
      final item = await _service.getUsersById(id);
      return item != null 
          ? Response.ok(ApiResponse.success(item).toJson())
          : Response.notFound(ApiResponse.error('Users no encontrado').toJson());
    } catch (e) {
      return Response.internalServerError(
        body: ApiResponse.error('Error al obtener users').toJson(),
      );
    }
  }
}
