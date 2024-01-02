import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '_schema.dart';

part 'schema_account.g.dart';

@Collection(inheritance: false)
class Account extends Equatable {
  Account({
    required this.id,
    required this.name,
    required this.cash,
    required this.image,
    required this.balance,
  });

  static const String schema = 'account';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String cashKey = 'cash';
  static const String imageKey = 'image';
  static const String balanceKey = 'balance';
  static const String countryKey = 'country';

  Id get isarId => id.fastHash;

  final String id;
  final bool? cash;
  final String name;
  final String image;
  final double? balance;

  /// Edges
  final country = IsarLink<Country>();

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
      image,
      cash,
      balance,
      country,
    ];
  }

  Account copyWith({
    String? id,
    bool? cash,
    String? name,
    String? image,
    double? balance,
    Country? country,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      cash: cash ?? this.cash,
      image: image ?? this.image,
      balance: balance ?? this.balance,
    )..country.value = country ?? this.country.value;
  }

  Account clone() {
    return copyWith(
      id: id,
      name: name,
      cash: cash,
      image: image,
      balance: balance,
      country: country.value,
    );
  }

  static Account? fromMap(dynamic data) {
    if (data == null) return null;
    return Account(
      id: data[idKey],
      name: data[nameKey],
      cash: data[cashKey],
      image: data[imageKey],
      balance: data[balanceKey],
    )..country.value = Country.fromMap(data[countryKey]);
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      cashKey: cash,
      imageKey: image,
      balanceKey: balance,
      countryKey: country.value,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      cashKey: cash,
      balanceKey: balance,
      nameKey: name.json(),
      imageKey: image.json(),
      countryKey: country.value?.toSurreal(),
    }..removeWhere((key, value) => value == null);
  }

  static Account fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static int accountSort(Account a, Account b) {
    if (a.cash != null && a.cash!) {
      return -1;
    } else if (b.cash != null && b.cash!) {
      return 1;
    }
    return (b.balance ?? 0).compareTo(a.balance ?? 0);
  }
}
