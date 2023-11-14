import 'dart:io';

import 'package:dio/dio.dart';

import '_service.dart';

Dio get dio => RepositoryService._internalDio!;

class RepositoryService {
  const RepositoryService._();

  static Dio? _internalDio;
  static const _connectTimeout = Duration(seconds: 5);
  static const _receiveTimeout = Duration(seconds: 5);
  static const _baseUrl = 'https://dei-surrealdb.fly.dev';

  static String? _namespace;
  static String get namespace => _namespace!;
  static String? _database;
  static String get database => _database!;
  static String? _scope;
  static String get scope => _scope!;

  static void _createDio() {
    _internalDio ??= Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        'NS': namespace,
        'DB': database,
        'SC': scope,
      },
    ));
    _internalDio?.interceptors.add(
      const _AuthInterceptor(),
    );
  }

  static Future<void> development() async {
    _namespace = 'development';
    _database = 'moja';
    _scope = 'agent';

    _createDio();
  }

  static Future<void> production() async {
    _namespace = 'production';
    _database = 'moja';
    _scope = 'agent';

    _createDio();
  }
}

class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor();
  static const _bearerKey = 'Bearer';

  @override
  void onRequest(options, handler) async {
    final token = Database.token;
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = '$_bearerKey $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future onError(err, handler) async {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      final token = await refreshToken();
      if (token != null) {
        err.requestOptions.headers[HttpHeaders.authorizationHeader] = '$_bearerKey $token';
        return handler.resolve(await dio.fetch(err.requestOptions));
      }
    }
    return super.onError(err, handler);
  }
}
