import 'dart:io';

import 'package:dio/dio.dart';

Dio get dio => RepositoryService._internalDio!;

Future<String> sql(String query) async {
  return dio.post<String>('/sql', data: query).then((value) => value.data!);
}

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

  static Dio _createDio() {
    return _internalDio ??= Dio(BaseOptions(
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
  }

  static Future<void> development() async {
    _namespace = 'development';
    _database = 'moja';
    _scope = 'agent';

    _createDio()
      ..interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
      ))
      ..interceptors.add(const _AuthInterceptor());
  }

  static Future<void> production() async {
    _namespace = 'production';
    _database = 'moja';
    _scope = 'agent';

    _createDio()
      ..interceptors.add(LogInterceptor())
      ..interceptors.add(const _AuthInterceptor());
  }
}

class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor();

  // static const _bearerKey = 'Bearer';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // if (false) {
    //   options.headers[HttpHeaders.authorizationHeader] = '$_bearerKey $token';
    // }
    return super.onRequest(options, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // if (err.response?.statusCode == HttpStatus.unauthorized) {
    //   const token = '';
    //   // final token = await _refreshToken();
    //   err.requestOptions.headers[HttpHeaders.authorizationHeader] = '$_bearerKey $token';
    //   return handler.resolve(await dio.fetch(err.requestOptions));
    // }
    return super.onError(err, handler);
  }
}
