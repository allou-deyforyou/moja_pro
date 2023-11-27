import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Geometry extends Equatable {
  const Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.point(double longitude, double latitude) {
    return Geometry(
      type: 'Point',
      coordinates: [longitude, latitude],
    );
  }

  static const String schema = 'geometry';

  static const String typeKey = 'type';
  static const String coordinatesKey = 'coordinates';

  final String type;
  final List<double> coordinates;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      type,
      coordinates,
    ];
  }

  Geometry copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return Geometry(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  Geometry clone() {
    return copyWith(
      type: type,
      coordinates: coordinates,
    );
  }

  static Geometry fromMap(dynamic data) {
    return Geometry(
      type: data[typeKey],
      coordinates: data[coordinatesKey].cast<double>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      typeKey: type,
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      typeKey: type.json(),
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  static Geometry fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
