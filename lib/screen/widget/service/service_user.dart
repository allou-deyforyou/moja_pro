import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<User?> get currentUserController => Singleton.instance(() => AsyncController<User?>(null), User.schema);

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
      final data = await compute(jsonEncode, {
        'ns': RepositoryService.namespace,
        'db': RepositoryService.database,
        'sc': RepositoryService.scope,
        'id_token': idToken,
      });
      final response = await dio.post<String>('/signin', data: data);
      final token = response.data!;
      return GetUserEvent(
        token: token,
        id: userId,
      ).handle(emit);
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
      final token = response.data!;
      return GetUserEvent(
        token: token,
        id: userId,
      ).handle(emit);
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
    required this.token,
  });
  final String id;
  final String token;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final source = await sql('SELECT * FROM ONLY $id');
      final data = await compute(User.fromListJson, source);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
