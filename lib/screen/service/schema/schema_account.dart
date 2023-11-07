import 'dart:convert';

import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.balance,
  });

  static const String schema = 'account';

  static const String nameKey = 'name';
  static const String idKey = 'id';
  static const String balanceKey = 'balance';

  final String id;
  final String name;
  final double? balance;

  List<double> get balanceSuggestions {
    return [];
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      balance,
    ];
  }

  Account copyWith({
    String? id,
    String? name,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
    );
  }

  Account clone() {
    return copyWith(
      id: id,
      name: name,
      balance: balance,
    );
  }

  static Account fromMap(dynamic data) {
    return Account(
      id: data[idKey],
      name: data[nameKey],
      balance: data[balanceKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      balanceKey: balance,
    }..removeWhere((key, value) => value == null);
  }

  static List<Account> fromListMap(dynamic data) {
    return List.of((data as List).map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Account> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Account fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Account> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Account> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
