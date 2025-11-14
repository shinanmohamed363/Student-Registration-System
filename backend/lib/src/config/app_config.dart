import 'dart:io';
import 'package:dotenv/dotenv.dart';

/// Application configuration class that loads and manages environment variables
/// This class follows the Singleton pattern to ensure only one instance exists
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  late DotEnv _env;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  /// Initialize configuration by loading environment variables
  void init() {
    _env = DotEnv()..load();
  }

  // Database Configuration
  String get dbHost => _env['DB_HOST'] ?? '127.0.0.1';
  int get dbPort => int.parse(_env['DB_PORT'] ?? '3306');
  String get dbName => _env['DB_NAME'] ?? 'studentregistrationsystemdb';
  String get dbUser => _env['DB_USER'] ?? 'root';
  String get dbPassword => _env['DB_PASSWORD'] ?? '';

  // Server Configuration
  String get serverHost => _env['SERVER_HOST'] ?? 'localhost';
  int get serverPort => int.parse(_env['SERVER_PORT'] ?? '8080');

  // JWT Configuration
  String get jwtSecret => _env['JWT_SECRET'] ?? 'default_secret_key';
  int get jwtExpiryHours => int.parse(_env['JWT_EXPIRY_HOURS'] ?? '24');
}
