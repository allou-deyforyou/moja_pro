import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'config_repository.dart';

Future<Iterable<Object>> sql(String query) async {
  final response = await dio.post<String>('/sql', data: query);
  final data = await compute(_Response.fromListJson, response.data!);
  return data.map((res) => res.result!);
}

class _Response {
  const _Response({
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

  static _Response fromMap(dynamic data) {
    return _Response(
      id: data[idKey],
      error: data[errorKey],
      result: data[resultKey],
    );
  }

  static Iterable<_Response> fromListJson(String source) {
    return (jsonDecode(source) as List).map(fromMap);
  }
}
