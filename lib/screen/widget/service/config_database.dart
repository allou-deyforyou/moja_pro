import 'package:hive_flutter/hive_flutter.dart';

class DatabaseConfig {
  const DatabaseConfig._();

  static const _tokenKey = 'token';
  static const _settingsKey = 'settings';

  static Box<dynamic>? _settings;
  static Box<dynamic> get settings => _settings!;

  static String? get token {
    return DatabaseConfig.settings.get(_tokenKey);
  }

  static set token(String? value) {
    DatabaseConfig.settings.put(_tokenKey, value);
  }

  static Future<void> development() async {
    await Hive.initFlutter('development');
    _settings = await Hive.openBox(_settingsKey);
  }

  static Future<void> production() async {
    await Hive.initFlutter('production');
    _settings = await Hive.openBox(_settingsKey);
  }
}
