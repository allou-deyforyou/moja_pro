import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

Future<List<double>> generateSuggestions(double amount) {
  return compute(_generateSuggestions, amount);
}

List<double> _generateSuggestions(double amount) {
  double generateAmount(int amount) {
    Random random = Random();
    double result = (random.nextInt(max(1000, amount)) / 1000).round() * 1000.0;
    return result.clamp(1000.0, 2000000.0);
  }

  List<double> result = [];
  for (int i = 0; i < 10; i++) {
    double amount1 = generateAmount(amount.toInt() + 100000);
    double amount2 = generateAmount(amount.toInt() - 100000);
    result.addAll([amount1, amount2]);
  }
  result.sort();

  return Set.of(result).toList();
}
