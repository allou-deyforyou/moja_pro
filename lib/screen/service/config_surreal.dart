import 'package:surrealdb_dart/surrealdb_dart.dart';

class SurrealConfig {
  const SurrealConfig._();

  static String? _httpUrl;
  static String get httpUrl => _httpUrl!;

  static String? _wsUrl;
  static String get wsUrl => _wsUrl!;

  static String? _namespace;
  static String get namespace => _namespace!;
  static String? _database;
  static String get database => _database!;
  static String? _scope;
  static String get scope => _scope!;

  static SurrealDB? _client;
  static SurrealDB get client {
    return _client ??= SurrealDB.connect(
      Uri.parse(wsUrl),
      onConnected: (db) async {
        return db.use(
          namespace: namespace,
          database: database,
        );
      },
    );
  }

  static Future<void> development() async {
    _wsUrl = 'wss://dei-surrealdb.fly.dev/rpc';
    _namespace = 'development';
    _database = 'moja';
    _scope = 'agent';
  }

  static Future<void> production() async {
    _wsUrl = 'wss://dei-surrealdb.fly.dev/rpc';
    _namespace = 'production';
    _database = 'moja';
    _scope = 'agent';
  }
}
