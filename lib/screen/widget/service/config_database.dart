import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '_service.dart';

class DatabaseConfig {
  const DatabaseConfig._();

  static const _tokenKey = 'token';
  static const _localeKey = 'locale';
  static const _themeModeKey = 'theme_mode';
  static const _currentUserKey = 'current_user';
  static const _notificationsKey = 'notifications';

  static const _settingsBoxKey = 'settings';
  static Box<dynamic>? _settingsBox;
  static Box<dynamic> get settingsBox => _settingsBox!;

  static set relays(List<Relay>? values) {
    if (values == null) return;
    final relays = DatabaseConfig.currentUser!.relays!;
    for (var item in values) {
      final index = relays.indexOf(item);
      relays[index] = item;
    }
    DatabaseConfig.currentUser = DatabaseConfig.currentUser!.copyWith(
      relays: relays,
    );
  }

  static User? get currentUser {
    final data = DatabaseConfig.settingsBox.get(_currentUserKey);
    if (data == null) return null;
    return User.fromJson(data);
  }

  static set currentUser(User? value) {
    DatabaseConfig.settingsBox.put(_currentUserKey, value?.toJson());
  }

  static String? get token {
    return DatabaseConfig.settingsBox.get(_tokenKey);
  }

  static set token(String? value) {
    DatabaseConfig.settingsBox.put(_tokenKey, value);
  }

  static Stream<bool> get notificationsStream {
    return settingsBox.watch(key: _notificationsKey).asyncMap(
          (event) => event.value,
        );
  }

  static bool get notifications {
    return DatabaseConfig.settingsBox.get(
      defaultValue: false,
      _notificationsKey,
    );
  }

  static set notifications(bool notifications) {
    DatabaseConfig.settingsBox.put(_notificationsKey, notifications);
  }

  static Stream<Locale> get localeStream {
    return settingsBox.watch(key: _localeKey).asyncMap(
          (event) => Locale(event.value),
        );
  }

  static Locale? get locale {
    final value = DatabaseConfig.settingsBox.get(_localeKey, defaultValue: null);
    return value != null ? Locale(value) : null;
  }

  static set locale(Locale? locale) {
    DatabaseConfig.settingsBox.put(_localeKey, locale?.languageCode);
  }

  static ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Stream<ThemeMode> get themeModeStream {
    return settingsBox.watch(key: _themeModeKey).asyncMap(
          (event) => _parseThemeMode(event.value),
        );
  }

  static ThemeMode get themeMode {
    return _parseThemeMode(DatabaseConfig.settingsBox.get(
      defaultValue: ThemeMode.system.name,
      _themeModeKey,
    ));
  }

  static set themeMode(ThemeMode themeMode) {
    DatabaseConfig.settingsBox.put(_themeModeKey, themeMode.name);
  }

  static Future<void> development() async {
    await Hive.initFlutter('development');
    _settingsBox = await Hive.openBox(_settingsBoxKey);
  }

  static Future<void> production() async {
    await Hive.initFlutter('production');
    _settingsBox = await Hive.openBox(_settingsBoxKey);
  }
}
