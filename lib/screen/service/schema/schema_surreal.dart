import 'dart:convert';

import 'package:flutter/foundation.dart';

class SurrealResponse {
  const SurrealResponse({
    required this.id,
    required this.error,
    required this.result,
  });

  static const String idKey = 'id';
  static const String errorKey = 'error';
  static const String resultKey = 'result';

  final String? id;
  final Object? error;
  final Object? result;

  SurrealResponse copyWith({
    String? id,
    Object? error,
    Object? result,
  }) {
    return SurrealResponse(
      id: id ?? this.id,
      error: error ?? this.error,
      result: result ?? this.result,
    );
  }

  SurrealResponse clone() {
    return copyWith(
      id: id,
      error: error,
      result: result,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static SurrealResponse fromMap(Map<String, dynamic> data) {
    return SurrealResponse(
      id: data[idKey],
      error: data[errorKey],
      result: data[resultKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      errorKey: error,
      resultKey: result,
    };
  }

  static List<SurrealResponse> fromListMap(List<Map<String, dynamic>> data) {
    return List.of(data.map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<SurrealResponse> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static List<SurrealResponse> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static SurrealResponse fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static Future<SurrealResponse> fromComputeJson(String source) {
    return compute(fromJson, source);
  }

  static Future<List<SurrealResponse>> fromComputeListJson(String source) {
    return compute(fromListJson, source);
  }

  Future<String> toComputeJson() {
    return compute(jsonEncode, toMap());
  }
}
