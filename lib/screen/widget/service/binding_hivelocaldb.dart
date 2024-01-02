import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HiveLocalDB {
  const HiveLocalDB._();

  static Future<void> development() async {
    tz.initializeTimeZones();
    _currentTimeZone = await FlutterTimezone.getLocalTimezone();

    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(
      collection: '/development',
      _settingsBoxKey,
    );
  }

  static Future<void> production() async {
    tz.initializeTimeZones();
    _currentTimeZone = await FlutterTimezone.getLocalTimezone();

    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(
      collection: '/production',
      _settingsBoxKey,
    );
  }

  static String? _currentTimeZone;
  static String get currentTimeZone => _currentTimeZone!;

  static const _settingsBoxKey = 'settings';
  static Box<dynamic>? _settingsBox;
  static Box<dynamic> get settingsBox => _settingsBox!;

  /// token
  static const _tokenKey = 'token';
  static String? get token {
    return HiveLocalDB.settingsBox.get(_tokenKey);
  }

  static set token(String? value) {
    HiveLocalDB.settingsBox.put(_tokenKey, value);
  }

  /// notifications
  static const _notificationsKey = 'notifications';

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

  /// locale
  static const _localeKey = 'locale';

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

  /// ThemeMode
  static const _themeModeKey = 'theme_mode';

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

  static ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// inAppReview
  static const _inAppReviewKey = 'in-app-review';

  static Future<void> showInAppReview([bool force = false]) async {
    final InAppReview inAppReview = InAppReview.instance;
    if (!(await inAppReview.isAvailable())) return;

    if (force) return inAppReview.requestReview();

    final now = tz.TZDateTime.from(
      DateTime.now(),
      tz.getLocation(HiveLocalDB.currentTimeZone),
    );

    final scheduledDate = now.add(const Duration(days: 7));
    final DateTime schedule = HiveLocalDB.settingsBox.get(
      defaultValue: scheduledDate,
      _inAppReviewKey,
    );

    final duration = schedule.difference(now);
    if (duration.isNegative) {
      inAppReview.requestReview();
      HiveLocalDB.settingsBox.put(_inAppReviewKey, scheduledDate);
    } else {
      Timer(duration, () {
        inAppReview.requestReview();
        HiveLocalDB.settingsBox.put(_inAppReviewKey, scheduledDate);
      });
    }
  }
}
