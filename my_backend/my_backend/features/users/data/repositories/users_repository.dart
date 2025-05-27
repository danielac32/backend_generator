import '../../domain/interfaces/i_users_repository.dart';
import '../../domain/entities/users_entity.dart';
import '../../shared/config/database_config.dart';

class UsersRepository implements IUsersRepository {
  @override
  Future<UsersEntity> create(UsersEntity entity) async {
    // Implementación concreta de creación
    throw UnimplementedError();
  }

  @override
  Future<List<UsersEntity>> getAll() async {
    // Implementación concreta para obtener todos
    throw UnimplementedError();
  }

  @override
  Future<UsersEntity?> getById(String id) async {
    // Implementación concreta para obtener por ID
    throw UnimplementedError();
  }

  @override
  Future<UsersEntity> update(String id, UsersEntity entity) async {
    // Implementación concreta de actualización
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String id) async {
    // Implementación concreta de eliminación
    throw UnimplementedError();
  }
}
