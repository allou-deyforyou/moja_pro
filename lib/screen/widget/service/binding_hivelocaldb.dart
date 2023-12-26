import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveLocalDB {
  const HiveLocalDB._();

  static const _tokenKey = 'token';
  static const _localeKey = 'locale';
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications';

  static const _settingsBoxKey = 'settings';
  static Box<dynamic>? _settingsBox;
  static Box<dynamic> get settingsBox => _settingsBox!;

  static String? get token {
    return HiveLocalDB.settingsBox.get(_tokenKey);
  }

  static set token(String? value) {
    HiveLocalDB.settingsBox.put(_tokenKey, value);
  }

  static Stream<bool?> get notificationsStream {
    return settingsBox.watch(key: _notificationsKey).asyncMap(
          (event) => event.value,
        );
  }

  static bool? get notifications {
    return HiveLocalDB.settingsBox.get(
      defaultValue: false,
      _notificationsKey,
    );
  }

  static set notifications(bool? notifications) {
    HiveLocalDB.settingsBox.put(_notificationsKey, notifications);
  }

  static Stream<Locale?> get localeStream {
    return HiveLocalDB.settingsBox.watch(key: _localeKey).asyncMap(
          (event) => HiveLocalDB.locale,
        );
  }

  static Locale? get locale {
    return Locale(HiveLocalDB.settingsBox.get(
      defaultValue: "system",
      _localeKey,
    ));
  }

  static set locale(Locale? locale) {
    HiveLocalDB.settingsBox.put(_localeKey, locale?.languageCode);
  }

  static ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Stream<ThemeMode> get themeModeStream {
    return HiveLocalDB.settingsBox.watch(key: _themeModeKey).asyncMap(
          (event) => HiveLocalDB.themeMode,
        );
  }

  static ThemeMode get themeMode {
    return _parseThemeMode(HiveLocalDB.settingsBox.get(
      defaultValue: ThemeMode.system.name,
      _themeModeKey,
    ));
  }

  static set themeMode(ThemeMode themeMode) {
    HiveLocalDB.settingsBox.put(_themeModeKey, themeMode.name);
  }

  static Future<void> development() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(
      collection: 'development',
      _settingsBoxKey,
    );
  }

  static Future<void> production() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(
      collection: 'production',
      _settingsBoxKey,
    );
  }
}
