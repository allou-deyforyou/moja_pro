import 'package:hive_flutter/hive_flutter.dart';

class Database {
  const Database._();

  static const _tokenKey = 'token';
  static const _settingsKey = 'settings';

  static Box<dynamic>? _settings;
  static Box<dynamic> get settings => _settings!;

  static String? get token {
    return Database.settings.get(_tokenKey);
  }

  static set token(String? value) {
    Database.settings.put(_tokenKey, value);
  }

  static Future<void> development() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(_settingsKey);
  }

  static Future<void> production() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(_settingsKey);
  }
}
