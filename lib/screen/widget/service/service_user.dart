import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:service_tools/service_tools.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_service.dart';

AsyncController<User?> get currentUser {
  final uid = FirebaseConfig.firebaseAuth.currentUser?.uid;
  final user = IsarLocalDB.isar.users.getSync('${User.schema}:$uid'.fastHash);
  user?.country.loadSync();

  return singleton(
    AsyncController<User?>(user),
    User.schema,
  );
}

Future<String?> refreshToken({String? uid, String? idToken}) async {
  final user = FirebaseConfig.firebaseAuth.currentUser;
  uid ??= user?.uid;
  idToken ??= await user?.getIdToken();

  final userId = '${User.schema}:$uid';
  final data = await compute(jsonEncode, {
    'ns': SurrealConfig.namespace,
    'db': SurrealConfig.database,
    'sc': SurrealConfig.scope,
    '${User.schema}_${User.idKey}': userId,
    'id_token': idToken,
  });
  final response = await dio.post<String>(
    data: data,
    '/signin',
  );
  final result = await compute(jsonDecode, response.data!);
  HiveLocalDB.token = result['token'];
  return HiveLocalDB.token;
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
      await refreshToken(uid: uid, idToken: idToken);
      final userId = '${User.schema}:$uid';

      emit(SuccessState(userId, event: this));

      await Future.wait([
        FirebaseConfig.firebaseAnalytics.setUserId(id: userId),
        FirebaseConfig.firebaseCrashlytics.setUserIdentifier(userId),
      ]);

      await Future.wait([
        FirebaseConfig.firebaseAnalytics.logLogin(
          loginMethod: 'auth-phone',
        ),
      ]);
    } on DioException catch (error) {
      emit(FailureState(
        switch (error.type) {
          DioExceptionType.badResponse => 'no-record',
          _ => 'no-internet',
        },
        event: this,
      ));
    } catch (error) {
      emit(FailureState(
        'internal-error',
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
        'ns': SurrealConfig.namespace,
        'db': SurrealConfig.database,
        'sc': SurrealConfig.scope,
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
      HiveLocalDB.token = result['token'];

      emit(SuccessState(userId, event: this));

      await Future.wait([
        FirebaseConfig.firebaseAnalytics.setUserId(id: userId),
        FirebaseConfig.firebaseCrashlytics.setUserIdentifier(userId),
      ]);

      await Future.wait([
        FirebaseConfig.firebaseAnalytics.logSignUp(
          signUpMethod: 'auth-phone',
        ),
      ]);
    } on DioException catch (error) {
      emit(FailureState(
        switch (error.type) {
          DioExceptionType.badResponse => 'already-exists',
          _ => 'no-internet',
        },
        event: this,
      ));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SignOutUserEvent extends AsyncEvent<AsyncState> {
  const SignOutUserEvent();

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await FirebaseConfig.firebaseAnalytics.logEvent(
        name: 'sign_out',
      );

      await Future.wait([
        HiveLocalDB.settingsBox.clear(),
        IsarLocalDB.isar.close(deleteFromDisk: true),
      ]);

      await FirebaseConfig.firebaseAnalytics.resetAnalyticsData();

      await runService(const MyService());

      NotificationConfig.hideAvailabilityNotification();
      currentUser.value = null;
      currentCountry.reset();
      currentAuth.reset();

      emit(const InitState());
    } catch (error) {
      emit(FailureState(
        'internal-error',
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

      const accountQuery = '(SELECT *, array::first(<-created.balance) as balance FROM ${Account.schema}) AS accounts';
      const relayFilters = 'WHERE <-worked<-(${User.schema} WHERE ${User.idKey} = \$parent.id)';
      const relayQuery = 'SELECT *, $accountQuery FROM ${Relay.schema} $relayFilters';

      final responses = await sql('SELECT *, country.*, ($relayQuery) AS ${Relay.schema}s FROM ONLY $id');

      final data = User.fromMap(responses.first)!;

      await Future.wait([
        SaveUserEvent(users: [data]).handle(emit),
      ]);

      emit(SuccessState(data, event: this));

      FirebaseConfig.firebaseAnalytics.setUserProperty(
        name: User.phoneKey,
        value: data.phone,
      );
      FirebaseConfig.firebaseAnalytics.setUserProperty(
        value: data.createdAt?.toString(),
        name: User.createdAtKey,
      );
      for (final relay in data.relays) {
        FirebaseConfig.firebaseAnalytics.setUserProperty(
          value: relay.name,
          name: 'relay',
        );
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SetUserEvent extends AsyncEvent<AsyncState> {
  const SetUserEvent({
    required this.user,
    this.phone,
  });
  final User user;
  final String? phone;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = user.id;
      final values = {
        User.phoneKey: phone?.json(),
      }..removeWhere((key, value) => value == null);

      final responses = await sql('UPDATE ONLY $id MERGE $values;');
      final data = User.fromMap(responses.first)!;

      await Future.wait([
        SaveUserEvent(users: [data]).handle(emit),
      ]);

      emit(SuccessState(data, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class LoadUserEvent extends AsyncEvent<AsyncState> {
  const LoadUserEvent({
    required this.userId,
    this.fireImmediately = false,
    this.listen = false,
  });
  final bool listen;
  final bool fireImmediately;
  final String userId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (listen) {
        final stream = IsarLocalDB.isar.users.watchObject(
          fireImmediately: fireImmediately,
          userId.fastHash,
        );
        await stream.forEach((data) {
          if (data != null) {
            emit(SuccessState(data, event: this));
          } else {
            emit(FailureState(
              'no-record',
              event: this,
            ));
          }
        });
      } else {
        final data = await IsarLocalDB.isar.users.get(
          userId.fastHash,
        );
        if (data != null) {
          emit(SuccessState(data, event: this));
        } else {
          emit(FailureState(
            'no-record',
            event: this,
          ));
        }
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SaveUserEvent extends AsyncEvent<AsyncState> {
  const SaveUserEvent({
    required this.users,
  });
  final List<User> users;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await IsarLocalDB.isar.writeTxn(() async {
        return IsarLocalDB.isar.users.putAll(users);
      });
      await Future.wait([
        SaveCountryEvent(
          countries: List.of(users.expand((item) => [item.country.value!])),
        ).handle(emit),
        SaveRelayEvent(
          relays: List.of(users.expand((item) => item.relays)),
        ).handle(emit),
      ]);
      await IsarLocalDB.isar.writeTxn(() async {
        return Future.wait([
          ...users.map((item) => item.country.save()),
          ...users.map((item) => item.relays.save()),
        ]);
      });

      emit(SuccessState(users, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
