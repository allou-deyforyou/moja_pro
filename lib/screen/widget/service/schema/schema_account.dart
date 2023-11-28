import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '_schema.dart';

part 'schema_account.g.dart';

@Collection(inheritance: false)
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

  Id get isarId => id.fastHash;

  final String id;
  final String name;
  final double? balance;

  @override
  String toString() {
    return toMap().toString();
  }

  @ignore
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

  static Account? fromMap(dynamic data) {
    if (data == null) return null;
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

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      balanceKey: balance,
      nameKey: name.json(),
    }..removeWhere((key, value) => value == null);
  }

  static Account fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
