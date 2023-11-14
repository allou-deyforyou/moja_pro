import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<User?> get currentUser => singleton(AsyncController<User?>(null), User.schema);

Future<String?> refreshToken({
  String? uid,
  String? idToken,
}) async {
  final user = FirebaseConfig.firebaseAuth.currentUser;
  if (user == null) return null;

  uid ??= user.uid;
  idToken ??= await user.getIdToken();

  final userId = '${User.schema}:$uid';
  final data = await compute(jsonEncode, {
    'ns': RepositoryService.namespace,
    'db': RepositoryService.database,
    'sc': RepositoryService.scope,
    '${User.schema}_${User.idKey}': userId,
    'id_token': idToken,
  });
  final response = await dio.post<String>(
    data: data,
    '/signin',
  );
  final result = await compute(jsonDecode, response.data!);
  Database.token = result['token'];
  return Database.token;
}

class SigninUserEvent extends AsyncEvent<AsyncState> {
  const SigninUserEvent({
    required this.uid,
    required this.idToken,
  });
  final String uid;
  final String idToken;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final userId = '${User.schema}:$uid';
      await refreshToken(uid: uid, idToken: idToken);
      return GetUserEvent(id: userId).handle(emit);
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.badResponse:
          emit(FailureState(
            code: 'no-record',
            event: this,
          ));
          break;
        default:
          emit(FailureState(
            code: 'internal-error',
            event: this,
          ));
      }
    } catch (error) {
      emit(FailureState(
        code: 'internal-error',
        event: this,
      ));
    }
  }
}

class SignupUserEvent extends AsyncEvent<AsyncState> {
  const SignupUserEvent({
    required this.uid,
    required this.userPhone,
    required this.relayName,
    required this.countryId,
  });
  final String uid;
  final String userPhone;
  final String relayName;
  final String countryId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final userId = '${User.schema}:$uid';
      final data = await compute(jsonEncode, {
        'ns': RepositoryService.namespace,
        'db': RepositoryService.database,
        'sc': RepositoryService.scope,
        '${Country.schema}_${Country.idKey}': countryId,
        '${Relay.schema}_${Relay.nameKey}': relayName,
        '${User.schema}_${User.phoneKey}': userPhone,
        '${User.schema}_${User.idKey}': userId,
      });
      final response = await dio.post<String>(
        data: data,
        '/signup',
      );
      final result = await compute(jsonDecode, response.data!);
      Database.token = result['token'];
      return GetUserEvent(id: userId).handle(emit);
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class GetUserEvent extends AsyncEvent<AsyncState> {
  const GetUserEvent({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('SELECT * FROM ONLY $id');
      final data = User.fromMap(responses.first);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
