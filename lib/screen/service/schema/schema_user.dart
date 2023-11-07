import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.phone,
    this.lastSign,
    this.createdAt,
    this.token,
    this.relays,
  });

  static const String schema = 'user';

  static const String idKey = 'id';
  static const String phoneKey = 'phone';
  static const String lastSignKey = 'last_sign';
  static const String createdAtKey = 'created_at';
  static const String relaysKey = 'relays';

  final String id;
  final String phone;
  final DateTime? lastSign;
  final DateTime? createdAt;
  final String? token;
  final List<Relay>? relays;

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      lastSign,
      createdAt,
      token,
      relays,
    ];
  }

  User copyWith({
    String? id,
    String? phone,
    DateTime? lastSign,
    DateTime? createdAt,
    String? token,
    List<Relay>? relays,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      lastSign: lastSign ?? this.lastSign,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
      relays: relays ?? this.relays,
    );
  }

  User clone() {
    return copyWith(
      id: id,
      phone: phone,
      lastSign: lastSign,
      createdAt: createdAt,
      token: token,
      relays: relays,
    );
  }

  static User fromMap(dynamic data) {
    return User(
      id: data[idKey],
      phone: data[phoneKey],
      relays: Relay.fromListMap(data[relaysKey] ?? []),
      lastSign: DateTime.tryParse(data[lastSignKey].toString()),
      createdAt: DateTime.tryParse(data[createdAtKey].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      phoneKey: phone,
      lastSignKey: lastSign?.toString(),
      createdAtKey: createdAt?.toString(),
      relaysKey: relays?.map((item) => item.toMap()),
    }..removeWhere((key, value) => value == null);
  }

  static List<User> fromListMap(dynamic data) {
    return List.of((data as List).map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<User> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static User fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<User> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<User> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
