import 'dart:async';

import 'package:listenable_tools/async.dart';
import 'package:surrealdb_dart/surrealdb_dart.dart';

import '_service.dart';

AsyncController<User?> get currentUserController => Singleton.instance(() => AsyncController<User?>(null), User.schema);

class GetUserEvent extends AsyncEvent<AsyncState> {
  const GetUserEvent({
    this.live = false,
    required this.id,
    this.token,
  });
  final bool live;
  final String id;
  final String? token;

  String get _rawSQL => r'''
SELECT
  *,
  (SELECT
    *,
    (SELECT id, name, array::first(<-created.balance) as balance FROM account)
  as accounts FROM relay WHERE <-works<-(user WHERE id = $parent.id)) as relays
FROM ONLY $id PARALLEL;
''';

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client.query(_rawSQL, vars: {
        'id': id,
      }).then(User.fromListMap);
      emit(SuccessState(data.first));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SetUserEvent extends AsyncEvent<AsyncState> {
  const SetUserEvent({
    this.id,
    this.phone,
    this.lastSign,
    this.createdAt,
    this.token,
  });
  final String? id;
  final String? phone;
  final DateTime? lastSign;
  final DateTime? createdAt;
  final String? token;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client
          .merge(
            id ?? User.schema,
            data: {
              User.phoneKey: phone,
              User.lastSignKey: lastSign,
              User.createdAtKey: createdAt,
            }..removeWhere((key, value) => value == null),
          )
          .then(User.fromMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class DeleteUserEvent extends AsyncEvent<AsyncState> {
  const DeleteUserEvent({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client.delete(id).then(User.fromMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
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
      final token = await SurrealConfig.client.signin(
        namespace: SurrealConfig.namespace,
        database: SurrealConfig.database,
        scope: SurrealConfig.scope,
        data: {'idToken': idToken},
      );
      return GetUserEvent(
        id: '${User.schema}:$uid',
        token: token,
      ).handle(emit);
    } on SurrealException catch (error) {
      switch (error.code) {
        case -32000:
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
    required this.phone,
    required this.relay,
    required this.country,
  });
  final String uid;
  final String phone;
  final String relay;
  final Country country;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final token = await SurrealConfig.client.signup(
        namespace: SurrealConfig.namespace,
        database: SurrealConfig.database,
        scope: SurrealConfig.scope,
        data: {
          'country_id': country.id,
          'relay_name': relay,
          'phone': phone,
          'uid': uid,
        },
      );
      await SurrealConfig.client.authenticate(token);
      return GetUserEvent(
        id: '${User.schema}:$uid',
        token: token,
      ).handle(emit);
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
