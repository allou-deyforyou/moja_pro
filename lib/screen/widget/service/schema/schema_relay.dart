import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Relay extends Equatable {
  const Relay({
    required this.id,
    required this.name,
    required this.location,
    required this.workdays,
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
  static const String workdaysKey = 'workdays';
  static const String accountsKey = 'accounts';
  static const String contactsKey = 'contacts';
  static const String availabilityKey = 'availability';
  static const String createdAtKey = 'created_at';

  final String id;
  final String name;
  final String? image;
  final Place? location;
  final bool? availability;
  final List<String>? contacts;
  final List<Weekday>? workdays;
  final List<Account>? accounts;

  final DateTime? createdAt;

  bool get isActive => availability ?? false;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      contacts,
      image,
      location,
      availability,
      workdays,
      accounts,
      createdAt,
    ];
  }

  Relay copyWith({
    String? id,
    String? name,
    String? image,
    Place? location,
    bool? availability,
    List<String>? contacts,
    List<Weekday>? workdays,
    List<Account>? accounts,
    DateTime? createdAt,
  }) {
    return Relay(
      id: id ?? this.id,
      name: name ?? this.name,
      contacts: contacts ?? this.contacts,
      image: image ?? this.image,
      location: location ?? this.location,
      workdays: workdays ?? this.workdays,
      accounts: accounts ?? this.accounts,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Relay clone() {
    return copyWith(
      id: id,
      name: name,
      image: image,
      contacts: contacts,
      location: location,
      workdays: workdays,
      accounts: accounts,
      availability: availability,
      createdAt: createdAt,
    );
  }

  static Relay fromMap(dynamic data) {
    return Relay(
      id: data[idKey],
      name: data[nameKey],
      image: data[imageKey],
      contacts: data[contactsKey],
      availability: data[availabilityKey],
      workdays: Weekday.fromListMap(data[workdaysKey] ?? []).cast<Weekday>(),
      accounts: Account.fromListMap(data[accountsKey] ?? []).cast<Account>(),
      location: data[locationKey] != null ? Place.fromMap(data[locationKey]) : null,
      createdAt: DateTime.tryParse(data[createdAtKey].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      imageKey: image,
      contactsKey: contacts,
      locationKey: location?.toMap(),
      availabilityKey: availability,
      workdaysKey: Weekday.toListMap(workdays?.toList() ?? []),
      accountsKey: Account.toListMap(accounts?.toList() ?? []),
      createdAtKey: createdAt?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  static List<Relay> fromListMap(dynamic data) {
    return List.of((data as List).map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Relay> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Relay fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Relay> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map(fromMap));
  }

  static String toListJson(List<Relay> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
