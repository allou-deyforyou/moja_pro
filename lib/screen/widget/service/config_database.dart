import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '_service.dart';

class DatabaseConfig {
  const DatabaseConfig._();

  static const _tokenKey = 'token';
  static const _localeKey = 'locale';
  static const _settingsKey = 'settings';
  static const _currentUserKey = 'currentUser';
  static const _notificationsKey = 'notifications';
  static const _themeModeKey = 'theme_mode';

  static Box<dynamic>? _settings;
  static Box<dynamic> get settings => _settings!;

  static User? get currentUser {
    final data = DatabaseConfig.settings.get(_currentUserKey);
    if (data == null) return null;
    return User.fromJson(data);
  }

  static set currentUser(User? value) {
    DatabaseConfig.settings.put(_currentUserKey, value?.toJson());
  }

  static String? get token {
    return DatabaseConfig.settings.get(_tokenKey);
  }

  static set token(String? value) {
    DatabaseConfig.settings.put(_tokenKey, value);
  }

  static Stream<bool> get notificationsStream {
    return settings.watch(key: _notificationsKey).asyncMap(
          (event) => event.value,
        );
  }

  static bool get notifications {
    return DatabaseConfig.settings.get(
      defaultValue: false,
      _notificationsKey,
    );
  }

  static set notifications(bool notifications) {
    DatabaseConfig.settings.put(_notificationsKey, notifications);
  }

  static Stream<Locale> get localeStream {
    return settings.watch(key: _localeKey).asyncMap(
          (event) => Locale(event.value),
        );
  }

  static Locale? get locale {
    final value = DatabaseConfig.settings.get(_localeKey, defaultValue: null);
    return value != null ? Locale(value) : null;
  }

  static set locale(Locale? locale) {
    DatabaseConfig.settings.put(_localeKey, locale?.languageCode);
  }

  static ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Stream<ThemeMode> get themeModeStream {
    return settings.watch(key: _themeModeKey).asyncMap(
          (event) => _parseThemeMode(event.value),
        );
  }

  static ThemeMode get themeMode {
    return _parseThemeMode(DatabaseConfig.settings.get(
      defaultValue: ThemeMode.system.name,
      _themeModeKey,
    ));
  }

  static set themeMode(ThemeMode themeMode) {
    DatabaseConfig.settings.put(_themeModeKey, themeMode.name);
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
