import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.phone,
    required this.relays,
    this.lastSign,
    this.createdAt,
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

  final List<Relay>? relays;

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      lastSign,
      createdAt,
      relays,
    ];
  }

  User copyWith({
    String? id,
    String? phone,
    DateTime? lastSign,
    DateTime? createdAt,
    List<Relay>? relays,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      lastSign: lastSign ?? this.lastSign,
      createdAt: createdAt ?? this.createdAt,
      relays: relays ?? this.relays,
    );
  }

  User clone() {
    return copyWith(
      id: id,
      phone: phone,
      lastSign: lastSign,
      createdAt: createdAt,
      relays: relays,
    );
  }

  static User fromMap(dynamic data) {
    return User(
      id: data[idKey],
      phone: data[phoneKey],
      lastSign: DateTime.tryParse(data[lastSignKey]),
      createdAt: DateTime.tryParse(data[createdAtKey]),
      relays: data[relaysKey]?.map<Relay>((data) => Relay.fromMap(data)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      phoneKey: phone,
      lastSignKey: lastSign?.toString(),
      createdAtKey: createdAt.toString(),
      relaysKey: relays?.map((data) => data.toMap()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  static User fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
