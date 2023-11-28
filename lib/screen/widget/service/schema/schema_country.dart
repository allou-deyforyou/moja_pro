import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '_schema.dart';

part 'schema_country.g.dart';

@Collection(inheritance: false)
class Country extends Equatable {
  const Country({
    this.id,
    this.code,
    this.dialCode,
    this.phoneFormat,
    this.translations,
  });

  static const String schema = 'country';

  static const String idKey = 'id';
  static const String codeKey = 'code';
  static const String dialCodeKey = 'dial_code';
  static const String phoneFormatKey = 'phone_format';
  static const String translationsKey = 'translations';

  Id? get isarId => id?.fastHash;

  final String? id;
  final String? code;
  final String? dialCode;
  @ignore
  final String? phoneFormat;
  @ignore
  final Map<String, String>? translations;

  @ignore
  @override
  List<Object?> get props {
    return [
      // id,
      code,
      dialCode,
      // phoneFormat,
      // translations,
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
    String? phoneFormat,
    Map<String, String>? translations,
  }) {
    return Country(
      id: id ?? this.id,
      code: code ?? this.code,
      dialCode: dialCode ?? this.dialCode,
      phoneFormat: phoneFormat ?? this.phoneFormat,
      translations: translations ?? this.translations,
    );
  }

  Country clone() {
    return copyWith(
      id: id,
      code: code,
      dialCode: dialCode,
      phoneFormat: phoneFormat,
      translations: translations,
    );
  }

  static Country fromMap(Map<String, dynamic> data) {
    return Country(
      id: data[idKey],
      code: data[codeKey],
      dialCode: data[dialCodeKey],
      phoneFormat: data[phoneFormatKey],
      translations: data[translationsKey]?.cast<String, String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      codeKey: code,
      dialCodeKey: dialCode,
      phoneFormatKey: phoneFormat,
      translationsKey: translations,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      codeKey: code?.json(),
      dialCodeKey: dialCode?.json(),
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
