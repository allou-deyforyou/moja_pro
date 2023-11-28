import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '_schema.dart';

part 'schema_place.g.dart';

@Embedded(inheritance: false)
class Place extends Equatable {
  const Place({
    this.city,
    this.name,
    this.state,
    this.country,
    this.locality,
    this.position,
  });

  static const String schema = 'place';

  static const String nameKey = 'name';
  static const String cityKey = 'city';
  static const String stateKey = 'state';
  static const String countryKey = 'country';
  static const String localityKey = 'locality';
  static const String positionKey = 'position';

  final String? city;
  final String? name;
  final String? state;
  final String? country;
  final String? locality;
  final Geometry? position;

  @ignore
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

  @ignore
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

  @ignore
  @override
  List<Object?> get props {
    return [
      city,
      name,
      state,
      country,
      locality,
      position,
    ];
  }

  Place copyWith({
    String? city,
    String? name,
    String? state,
    String? country,
    String? locality,
    Geometry? position,
  }) {
    return Place(
      city: city ?? this.city,
      name: name ?? this.name,
      state: state ?? this.state,
      country: country ?? this.country,
      locality: locality ?? this.locality,
      position: position ?? this.position,
    );
  }

  Place clone() {
    return copyWith(
      city: city,
      name: name,
      state: state,
      country: country,
      locality: locality,
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
