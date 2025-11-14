import 'package:mysql1/mysql1.dart';
import 'app_config.dart';

/// Database connection manager
/// Handles MySQL database connections using connection pooling for better performance
class Database {
  static Database? _instance;
  late ConnectionSettings _settings;
  MySqlConnection? _connection;

  Database._internal() {
    final config = AppConfig();
    _settings = ConnectionSettings(
      host: config.dbHost,
      port: config.dbPort,
      user: config.dbUser,
      password: config.dbPassword.isEmpty ? null : config.dbPassword,
      db: config.dbName,
    );
  }

  /// Get singleton instance of Database
  static Database get instance {
    _instance ??= Database._internal();
    return _instance!;
  }

  /// Get database connection
  /// Creates a new connection if one doesn't exist or has been closed
  Future<MySqlConnection> getConnection() async {
    try {
      // Check if connection exists and is still valid
      if (_connection != null) {
        try {
          // Test connection with a simple query
          await _connection!.query('SELECT 1');
          return _connection!;
        } catch (e) {
          // Connection is dead, close and reconnect
          await _connection?.close();
          _connection = null;
        }
      }

      // Create new connection
      _connection = await MySqlConnection.connect(_settings);
      print('Database connection established successfully');
      return _connection!;
    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    try {
      await _connection?.close();
      _connection = null;
      print('Database connection closed');
    } catch (e) {
      print('Error closing database connection: $e');
    }
  }

  /// Execute a query and return results
  Future<Results> query(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    return await conn.query(sql, values);
  }

  /// Execute a query and return single result
  Future<ResultRow?> queryOne(String sql, [List<Object?>? values]) async {
    final results = await query(sql, values);
    return results.isNotEmpty ? results.first : null;
  }

  /// Execute an insert query and return the inserted ID
  Future<int> insert(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    final results = await conn.query(sql, values);
    return results.insertId ?? 0;
  }

  /// Execute an update or delete query and return affected rows count
  Future<int> execute(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    final results = await conn.query(sql, values);
    return results.affectedRows ?? 0;
  }
}
