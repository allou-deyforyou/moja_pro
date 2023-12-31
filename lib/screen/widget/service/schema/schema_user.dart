import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:equatable/equatable.dart';

import '_schema.dart';

part 'schema_user.g.dart';

@Collection(inheritance: false)
class User extends Equatable {
  User({
    this.lastSign,
    this.createdAt,
    required this.id,
    required this.phone,
  });

  static const String schema = 'user';

  static const String idKey = 'id';
  static const String phoneKey = 'phone';
  static const String countryKey = 'country';
  static const String lastSignKey = 'last_sign';
  static const String createdAtKey = 'created_at';

  /// Edges
  static const String relaysKey = 'relays';

  Id get isarId => id.fastHash;

  final String id;
  final String phone;
  final DateTime? lastSign;
  final DateTime? createdAt;

  /// Edges
  final relays = IsarLinks<Relay>();
  final country = IsarLink<Country>();

  @ignore
  @override
  List<Object?> get props {
    return [
      id,
      phone,
      country,
      lastSign,
      createdAt,
    ];
  }

  User copyWith({
    String? id,
    String? phone,
    Country? country,
    DateTime? lastSign,
    DateTime? createdAt,

    /// Edges
    Iterable<Relay>? relays,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      lastSign: lastSign ?? this.lastSign,
      createdAt: createdAt ?? this.createdAt,
    )

      /// Edges
      ..relays.addAll(relays ?? this.relays)
      ..country.value = country ?? this.country.value;
  }

  User clone() {
    return copyWith(
      id: id,
      phone: phone,
      lastSign: lastSign,
      createdAt: createdAt,
      country: country.value,

      /// Edges
      relays: relays,
    );
  }

  static User? fromMap(dynamic data) {
    if (data == null) return null;
    return User(
      id: data[idKey],
      phone: data[phoneKey],
      lastSign: DateTime.tryParse(data[lastSignKey])?.toLocal(),
      createdAt: DateTime.tryParse(data[createdAtKey])?.toLocal(),
    )

      /// Edges
      ..country.value = Country.fromMap(data[countryKey])
      ..relays.addAll((data[relaysKey] ?? []).map<Relay>((data) => Relay.fromMap(data)!));
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      phoneKey: phone,
      countryKey: country.value,
      lastSignKey: lastSign?.toString(),
      createdAtKey: createdAt?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      phoneKey: phone.json(),
      lastSignKey: lastSign?.toString(),
      createdAtKey: createdAt?.toString(),
      countryKey: country.value?.toSurreal(),
    }..removeWhere((key, value) => value == null);
  }

  static User fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
