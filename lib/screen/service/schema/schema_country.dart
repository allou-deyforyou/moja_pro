import 'dart:convert';

import 'package:equatable/equatable.dart';

class Country extends Equatable {
  const Country({
    required this.id,
    required this.code,
    required this.dialCode,
  });

  static const String schema = 'country';

  static const String idKey = 'id';
  static const String codeKey = 'code';
  static const String dialCodeKey = 'dialcode';

  final String id;
  final String code;
  final String dialCode;

  @override
  List<Object?> get props {
    return [
      id,
      code,
      dialCode,
    ];
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Country copyWith({
    String? id,
    String? code,
    String? dialCode,
  }) {
    return Country(
      id: id ?? this.id,
      code: code ?? this.code,
      dialCode: dialCode ?? this.dialCode,
    );
  }

  Country clone() {
    return copyWith(
      id: id,
      code: code,
      dialCode: dialCode,
    );
  }

  static Country fromMap(Map<String, dynamic> data) {
    return Country(
      id: data[idKey],
      code: data[codeKey],
      dialCode: data[dialCodeKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      codeKey: code,
      dialCodeKey: dialCode,
    }..removeWhere((key, value) => value == null);
  }

  static List<Country> fromListMap(dynamic data) {
    return List.of((data as List<dynamic>).map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Country> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Country fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Country> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Country> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
