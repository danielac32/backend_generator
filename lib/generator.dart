import 'dart:io';
import 'package:path/path.dart';

class BackendGenerator {
  final String outputDir;
  final List<String> features;

  BackendGenerator({required this.outputDir, required this.features});

  Future<void> generate() async {
    try {
      print('🚀 Iniciando generación de estructura de backend...');

      // Verificar directorio de salida
      if (!await _ensureDirectoryExists(outputDir)) {
        throw Exception('No se pudo crear el directorio principal: $outputDir');
      }

      await _createBaseStructure();

      for (final feature in features) {
        await _generateFeature(feature);
      }

      print('✅ Generación completada exitosamente en: ${Directory(outputDir).absolute.path}');
    } catch (e) {
      print('❌ Error durante la generación: $e');
      rethrow;
    }
  }

  Future<bool> _ensureDirectoryExists(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('📁 Directorio creado: ${dir.absolute.path}');
      }
      return true;
    } catch (e) {
      print('⚠️ Error al verificar directorio $path: $e');
      return false;
    }
  }

  Future<void> _createBaseStructure() async {
    final sharedDirs = [
      'shared/config',
      'shared/utils',
      'shared/middlewares',
      'shared/constants',
      'features',
    ];

    for (final dir in sharedDirs) {
      final fullPath = join(outputDir, dir);
      if (!await _ensureDirectoryExists(fullPath)) {
        throw Exception('No se pudo crear directorio: $fullPath');
      }
    }

    // Archivos base compartidos
    await _createFileWithRetry(
        'shared/config/database_config.dart',
        _databaseConfigTemplate
    );
    await _createFileWithRetry(
        'shared/utils/api_response.dart',
        _apiResponseTemplate
    );
    await _createFileWithRetry(
        'shared/constants/app_constants.dart',
        _appConstantsTemplate
    );
  }

  Future<void> _generateFeature(String featureName) async {
    final featureDir = join(outputDir, 'features', featureName);
    if (!await _ensureDirectoryExists(featureDir)) {
      throw Exception('No se pudo crear directorio de feature: $featureDir');
    }

    final dirs = [
      'data/repositories',
      'domain/entities',
      'domain/interfaces',
      'presentation/controllers',
      'presentation/middlewares',
      'presentation/routes',
      'services',
    ];

    for (final dir in dirs) {
      final fullPath = join(featureDir, dir);
      if (!await _ensureDirectoryExists(fullPath)) {
        throw Exception('No se pudo crear subdirectorio: $fullPath');
      }
    }

    final className = _toPascalCase(featureName);
    await _generateCrudFiles(featureName, className);
  }

  Future<void> _generateCrudFiles(String featureName, String className) async {
    final templates = {
      'controller': _controllerTemplate,
      'interface': _interfaceTemplate,
      'repository': _repositoryTemplate,
      'service': _serviceTemplate,
      'middleware': _middlewareTemplate,
      'entity': _entityTemplate,
      'routes': _routesTemplate,
    };

    for (final entry in templates.entries) {
      try {
        final content = entry.value
            .replaceAll('{{FeatureName}}', className)
            .replaceAll('{{featureName}}', featureName.toLowerCase());

        final path = _getPathForFileType(featureName, entry.key);
        await _createFileWithRetry(path, content);
      } catch (e) {
        print('⚠️ Error al generar ${entry.key} para $featureName: $e');
      }
    }
  }

  String _getPathForFileType(String featureName, String type) {
    final base = join(outputDir, 'features', featureName);
    final fileName = '${featureName.toLowerCase()}_${type.replaceAll('controller', '').replaceAll('interface', 'i_repository')}.dart';

    switch (type) {
      case 'controller':
        return join(base, 'presentation', 'controllers', fileName);
      case 'interface':
        return join(base, 'domain', 'interfaces', fileName);
      case 'repository':
        return join(base, 'data', 'repositories', fileName);
      case 'service':
        return join(base, 'services', fileName);
      case 'middleware':
        return join(base, 'presentation', 'middlewares', fileName);
      case 'entity':
        return join(base, 'domain', 'entities', fileName);
      case 'routes':
        return join(base, 'presentation', 'routes', fileName);
      default:
        throw ArgumentError('Tipo de archivo no soportado: $type');
    }
  }

  Future<void> _createFileWithRetry(String relativePath, String content, {int retries = 2}) async {
    final fullPath = normalize(join(outputDir, relativePath));
    final file = File(fullPath);

    try {
      // Asegurarse que el directorio padre existe
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      if (await file.exists()) {
        print('ℹ️ Archivo ya existe, omitiendo: $fullPath');
        return;
      }

      await file.writeAsString(content);
      print('📄 Archivo creado: $fullPath');
    } catch (e) {
      print('❌ Error al crear archivo $fullPath: $e');
      rethrow;
    }
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return input;
    return input.split(RegExp(r'[_\s-]'))
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : '')
        .join();
  }

  // ========== PLANTILLAS DE CÓDIGO ==========

  final String _databaseConfigTemplate = '''
// Configuración de conexión a base de datos
class DatabaseConfig {
  static String get connectionString => const String.fromEnvironment(
    'DB_URL',
    defaultValue: 'postgres://user:pass@localhost:5432/db',
  );

  static Map<String, String> get connectionParams => {
    'host': 'localhost',
    'port': '5432',
    'database': 'db',
    'user': 'user',
    'password': 'pass',
  };
}
''';

  final String _apiResponseTemplate = '''
// Modelo estándar de respuesta API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.success(T data, [String? message]) => ApiResponse(
    success: true,
    message: message ?? 'Operación exitosa',
    data: data,
  );

  factory ApiResponse.error(String message, [String? errorCode]) => ApiResponse(
    success: false,
    message: message,
    errorCode: errorCode,
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
    'errorCode': errorCode,
  };
}
''';

  final String _appConstantsTemplate = '''
// Constantes globales de la aplicación
class AppConstants {
  static const String appName = 'My Backend';
  static const String apiVersion = 'v1';
  static const int defaultPageSize = 20;
  static const int maxFileSizeMB = 10;
}
''';

  final String _controllerTemplate = '''
import 'package:shelf/shelf.dart';
import '../../services/{{featureName}}_service.dart';
import '../../domain/entities/{{featureName}}_entity.dart';
import '../../shared/utils/api_response.dart';

class {{FeatureName}}Controller {
  final {{FeatureName}}Service _service;

  {{FeatureName}}Controller(this._service);

  Future<Response> getAll(Request request) async {
    try {
      final items = await _service.getAll{{FeatureName}}s();
      return Response.ok(ApiResponse.success(items).toJson());
    } catch (e) {
      return Response.internalServerError(
        body: ApiResponse.error('Error al obtener {{featureName}}s').toJson(),
      );
    }
  }

  Future<Response> getById(Request request, String id) async {
    try {
      final item = await _service.get{{FeatureName}}ById(id);
      return item != null 
          ? Response.ok(ApiResponse.success(item).toJson())
          : Response.notFound(ApiResponse.error('{{FeatureName}} no encontrado').toJson());
    } catch (e) {
      return Response.internalServerError(
        body: ApiResponse.error('Error al obtener {{featureName}}').toJson(),
      );
    }
  }
}
''';

  final String _interfaceTemplate = '''
import '../entities/{{featureName}}_entity.dart';

abstract class I{{FeatureName}}Repository {
  Future<{{FeatureName}}Entity> create({{FeatureName}}Entity entity);
  Future<List<{{FeatureName}}Entity>> getAll();
  Future<{{FeatureName}}Entity?> getById(String id);
  Future<{{FeatureName}}Entity> update(String id, {{FeatureName}}Entity entity);
  Future<bool> delete(String id);
}
''';

  final String _repositoryTemplate = '''
import '../../domain/interfaces/i_{{featureName}}_repository.dart';
import '../../domain/entities/{{featureName}}_entity.dart';
import '../../shared/config/database_config.dart';

class {{FeatureName}}Repository implements I{{FeatureName}}Repository {
  @override
  Future<{{FeatureName}}Entity> create({{FeatureName}}Entity entity) async {
    // Implementación concreta de creación
    throw UnimplementedError();
  }

  @override
  Future<List<{{FeatureName}}Entity>> getAll() async {
    // Implementación concreta para obtener todos
    throw UnimplementedError();
  }

  @override
  Future<{{FeatureName}}Entity?> getById(String id) async {
    // Implementación concreta para obtener por ID
    throw UnimplementedError();
  }

  @override
  Future<{{FeatureName}}Entity> update(String id, {{FeatureName}}Entity entity) async {
    // Implementación concreta de actualización
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String id) async {
    // Implementación concreta de eliminación
    throw UnimplementedError();
  }
}
''';

  final String _serviceTemplate = '''
import '../domain/interfaces/i_{{featureName}}_repository.dart';
import '../domain/entities/{{featureName}}_entity.dart';

class {{FeatureName}}Service {
  final I{{FeatureName}}Repository _repository;

  {{FeatureName}}Service(this._repository);

  Future<{{FeatureName}}Entity> create({{FeatureName}}Entity entity) async {
    return await _repository.create(entity);
  }

  Future<List<{{FeatureName}}Entity>> getAll{{FeatureName}}s() async {
    return await _repository.getAll();
  }

  Future<{{FeatureName}}Entity?> getById(String id) async {
    return await _repository.getById(id);
  }

  Future<{{FeatureName}}Entity> update(String id, {{FeatureName}}Entity entity) async {
    return await _repository.update(id, entity);
  }

  Future<bool> delete(String id) async {
    return await _repository.delete(id);
  }
}
''';

  final String _middlewareTemplate = '''
import 'package:shelf/shelf.dart';

Middleware {{featureName}}Middleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Ejemplo: Validación de headers
      if (request.headers['content-type'] != 'application/json') {
        return Response.badRequest(
          body: 'Content-Type must be application/json',
        );
      }

      // Ejemplo: Logging
      print('{{FeatureName}} Middleware: \${request.method} \${request.url.path}');

      return await innerHandler(request);
    };
  };
}
''';

  final String _entityTemplate = '''
class {{FeatureName}}Entity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  {{FeatureName}}Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory {{FeatureName}}Entity.fromJson(Map<String, dynamic> json) {
    return {{FeatureName}}Entity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => '{{FeatureName}}Entity(id: \$id)';
}
''';

  final String _routesTemplate = '''
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/{{featureName}}_controller.dart';
import '../middlewares/{{featureName}}_middleware.dart';

Router {{featureName}}Routes({{FeatureName}}Controller controller) {
  final router = Router();
  final middleware = {{featureName}}Middleware();

  router.get('/', (Request request) {
    return middleware(controller.getAll)(request);
  });

  router.get('/<id>', (Request request, String id) {
    return middleware(controller.getById)(request..params['id'] = id);
  });

  return router;
}
''';
}