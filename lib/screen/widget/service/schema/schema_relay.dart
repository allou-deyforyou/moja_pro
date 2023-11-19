import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Relay extends Equatable {
  const Relay({
    required this.id,
    required this.name,
    required this.location,
    required this.accounts,
    required this.contacts,
    this.image,
    this.availability,
    this.createdAt,
  });

  static const String schema = 'relay';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String imageKey = 'image';
  static const String locationKey = 'location';
  static const String accountsKey = 'accounts';
  static const String contactsKey = 'contacts';
  static const String availabilityKey = 'availability';
  static const String createdAtKey = 'created_at';

  final String id;
  final String name;
  final String? image;
  final Place? location;
  final DateTime? availability;
  final List<String>? contacts;
  final List<Account>? accounts;

  final DateTime? createdAt;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      contacts,
      image,
      location,
      availability,
      accounts,
      createdAt,
    ];
  }

  Relay copyWith({
    String? id,
    String? name,
    String? image,
    Place? location,
    DateTime? availability,
    List<String>? contacts,
    List<Account>? accounts,
    DateTime? createdAt,
  }) {
    return Relay(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      location: location ?? this.location,
      contacts: contacts ?? this.contacts,
      accounts: accounts ?? this.accounts,
      createdAt: createdAt ?? this.createdAt,
      availability: availability ?? this.availability,
    );
  }

  Relay clone() {
    return copyWith(
      id: id,
      name: name,
      image: image,
      contacts: contacts,
      location: location,
      accounts: accounts,
      createdAt: createdAt,
      availability: availability,
    );
  }

  static Relay fromMap(dynamic data) {
    return Relay(
      id: data[idKey],
      name: data[nameKey],
      image: data[imageKey],
      contacts: data[contactsKey]?.cast<String>(),
      location: null,
      // location: Place.fromMap(data[locationKey]),
      createdAt: DateTime.tryParse(data[createdAtKey].toString()),
      availability: DateTime.tryParse(data[availabilityKey].toString()),
      accounts: data[accountsKey]?.map<Account>((data) => Account.fromMap(data)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      imageKey: image,
      contactsKey: contacts,
      locationKey: location?.toMap(),
      createdAtKey: createdAt?.toString(),
      availabilityKey: availability?.toString(),
      accountsKey: accounts?.map((data) => data.toMap()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  static Relay fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
