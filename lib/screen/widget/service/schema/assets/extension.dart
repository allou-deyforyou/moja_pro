import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

NumberFormat get defaultNumberFormat => NumberFormat.currency(
      decimalDigits: 0,
      locale: "vi_VM",
      name: '',
    );

extension CustomBuildContext on BuildContext {
  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  CupertinoThemeData get cupertinoTheme {
    return CupertinoTheme.of(this);
  }

  AppLocalizations get localizations {
    return AppLocalizations.of(this)!;
  }
}

extension CustomString on String {
  int get fastHash {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < length) {
      final codeUnit = codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }

  String json() {
    return '"$this"';
  }

  String capitalize() {
    if (isNotEmpty) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }
    return this;
  }

  String trimSpace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  static String toFlag(String value) {
    return String.fromCharCodes(
      List.of(value.toUpperCase().codeUnits.map((code) => code + 127397)),
    );
  }
}

extension CustomDouble on double {
  String get formatted {
    return defaultNumberFormat.format(this).trim();
  }
}

extension CustomLocale on Locale {
  Locale? normalize() {
    if (languageCode == 'system') return null;
    return this;
  }

  String format(BuildContext context) {
    final localizations = context.localizations;
    return switch (languageCode) {
      'system' => localizations.system,
      'fr' => 'français',
      _ => 'english',
    };
  }
}

extension CustomThemeMode on ThemeMode {
  String format(BuildContext context) {
    final localizations = context.localizations;
    return switch (this) {
      ThemeMode.system => localizations.system,
      ThemeMode.light => localizations.light,
      ThemeMode.dark => localizations.dark,
    };
  }
}
