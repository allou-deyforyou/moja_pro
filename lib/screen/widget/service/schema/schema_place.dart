import 'dart:convert';

import 'package:equatable/equatable.dart';

typedef Point = ({
  double latitude,
  double longitude,
});

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
  final Point? position;

  String get title {
    if (city != null && locality != null) {
      return '$city $locality';
    } else if (locality != null && name != null) {
      return '$locality $name';
    }
    return name ?? '';
  }

  String get subtitle {
    if (state != null && city != null) {
      return '$state $city';
    } else if (city != null) {
      return city!;
    }
    return state ?? '';
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
    Point? position,
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

  static Place fromMap(dynamic data) {
    final position = data[positionKey];
    return Place(
      city: data[cityKey],
      name: data[nameKey],
      state: data[stateKey],
      country: data[countryKey],
      locality: data[localityKey],
      position: (
        latitude: position['latitude'],
        longitude: position['longitude'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      nameKey: name,
      cityKey: city,
      stateKey: state,
      countryKey: country,
      localityKey: locality,
      positionKey: position,
    }..removeWhere((key, value) => value == null);
  }

  static Place fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
