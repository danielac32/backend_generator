import '../domain/interfaces/i_users_repository.dart';
import '../domain/entities/users_entity.dart';

class UsersService {
  final IUsersRepository _repository;

  UsersService(this._repository);

  Future<UsersEntity> create(UsersEntity entity) async {
    return await _repository.create(entity);
  }

  Future<List<UsersEntity>> getAllUserss() async {
    return await _repository.getAll();
  }

  Future<UsersEntity?> getById(String id) async {
    return await _repository.getById(id);
  }

  Future<UsersEntity> update(String id, UsersEntity entity) async {
    return await _repository.update(id, entity);
  }

  Future<bool> delete(String id) async {
    return await _repository.delete(id);
  }
}
