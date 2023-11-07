import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

final defaultNumberFormat = NumberFormat.currency(
  decimalDigits: 0,
  locale: "fr_CI",
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
}

extension CustomString on String {
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
