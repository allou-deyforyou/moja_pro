import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Place extends Equatable {
  const Place({
    this.city,
    this.locality,
    this.state,
    this.name,
    this.country,
    this.position,
  });

  static const String schema = 'place';

  static const String cityKey = 'city';
  static const String localityKey = 'locality';
  static const String stateKey = 'state';
  static const String nameKey = 'name';
  static const String countryKey = 'country';
  static const String positionKey = 'position';

  final String? city;
  final String? locality;
  final String? state;
  final String? name;
  final String? country;
  final Geometry? position;

  String get title {
    List<String> words = name!.split(' ');
    if (city != null) {
      words.insertAll(0, city!.split(' '));
    } else if (locality != null) {
      words.insertAll(0, locality!.split(' '));
    }
    words = List.of(words.reversed);
    return words.toSet().toList().reversed.join(' ');
  }

  String get subtitle {
    List<String> words = country!.split(' ');
    if (state != null) {
      words.insertAll(0, state!.split(' '));
    }
    words = List.of(words.reversed);
    return words.toSet().toList().reversed.join(' ');
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      city,
      locality,
      state,
      name,
      country,
      position,
    ];
  }

  Place copyWith({
    String? city,
    String? locality,
    String? state,
    String? name,
    String? country,
    Geometry? position,
  }) {
    return Place(
      city: city ?? this.city,
      locality: locality ?? this.locality,
      state: state ?? this.state,
      name: name ?? this.name,
      country: country ?? this.country,
      position: position ?? this.position,
    );
  }

  Place clone() {
    return copyWith(
      city: city,
      locality: locality,
      state: state,
      name: name,
      country: country,
      position: position,
    );
  }

  static Place? fromMap(dynamic data) {
    if (data == null) return null;
    return Place(
      city: data[cityKey],
      name: data[nameKey],
      state: data[stateKey],
      country: data[countryKey],
      locality: data[localityKey],
      position: Geometry.fromMap(data[positionKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      nameKey: name,
      cityKey: city,
      stateKey: state,
      countryKey: country,
      localityKey: locality,
      positionKey: position?.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      nameKey: name?.json(),
      cityKey: city?.json(),
      stateKey: state?.json(),
      countryKey: country?.json(),
      localityKey: locality?.json(),
      positionKey: position?.toSurreal(),
    }..removeWhere((key, value) => value == null);
  }

  static Place fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
