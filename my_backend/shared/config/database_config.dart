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
