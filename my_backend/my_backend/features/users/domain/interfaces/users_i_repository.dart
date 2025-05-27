import '../entities/users_entity.dart';

abstract class IUsersRepository {
  Future<UsersEntity> create(UsersEntity entity);
  Future<List<UsersEntity>> getAll();
  Future<UsersEntity?> getById(String id);
  Future<UsersEntity> update(String id, UsersEntity entity);
  Future<bool> delete(String id);
}
