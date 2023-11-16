import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.phone,
    required this.relay,
    this.lastSign,
    this.createdAt,
  });

  static const String schema = 'user';

  static const String idKey = 'id';
  static const String phoneKey = 'phone';
  static const String lastSignKey = 'last_sign';
  static const String createdAtKey = 'created_at';
  static const String relayKey = 'relays';

  final String id;
  final String phone;
  final DateTime? lastSign;
  final DateTime? createdAt;

  final Relay relay;

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      lastSign,
      createdAt,
      relay,
    ];
  }

  User copyWith({
    String? id,
    String? phone,
    DateTime? lastSign,
    DateTime? createdAt,
    Relay? relay,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      lastSign: lastSign ?? this.lastSign,
      createdAt: createdAt ?? this.createdAt,
      relay: relay ?? this.relay,
    );
  }

  User clone() {
    return copyWith(
      id: id,
      phone: phone,
      lastSign: lastSign,
      createdAt: createdAt,
      relay: relay,
    );
  }

  static User fromMap(dynamic data) {
    return User(
      id: data[idKey],
      phone: data[phoneKey],
      relay: Relay.fromListMap(data[relayKey]).first,
      lastSign: DateTime.tryParse(data[lastSignKey]),
      createdAt: DateTime.tryParse(data[createdAtKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      phoneKey: phone,
      lastSignKey: lastSign,
      createdAtKey: createdAt,
      relayKey: [relay.toMap()],
    }..removeWhere((key, value) => value == null);
  }

  static List<User> fromListMap(dynamic data) {
    return List.of((data as List).map(fromMap));
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
    return List.of((jsonDecode(source) as List).map(fromMap));
  }

  static String toListJson(List<User> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
