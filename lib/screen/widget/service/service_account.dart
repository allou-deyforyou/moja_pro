import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SearchAccount extends AsyncEvent<AsyncState> {
  const SearchAccount({
    this.live = false,
    this.relayId,
    this.ids,
  });
  final bool live;
  final String? relayId;
  final List<String>? ids;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (relayId != null) {
        final data = await SurrealConfig.client
            .query(
              "SELECT *, array::first(SELECT balance FROM created WHERE in = $relayId) AS balance FROM account",
            )
            .then((value) => value!.first)
            .then(Account.fromListMap);
        emit(SuccessState(data));
      } else if (ids != null) {
        final data = await SurrealConfig.client
            .query(
              "SELECT *, array::first(SELECT balance FROM created WHERE out = \$parent.id) AS balance FROM $ids",
            )
            .then((value) => value!.first)
            .then(Account.fromListMap);
        emit(SuccessState(data));
      } else {
        final data = await SurrealConfig.client
            .query(
              "SELECT *, array::first(SELECT balance FROM created WHERE out = \$parent.id) AS balance FROM account",
            )
            .then((value) => value!.first)
            .then(Account.fromListMap);
        emit(SuccessState(data));
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class GetAccount extends AsyncEvent<AsyncState> {
  const GetAccount({
    this.live = false,
    required this.id,
  });
  final bool live;

  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client
          .query(
            "SELECT *, array::first(SELECT balance FROM created WHERE out = \$parent.id) AS balance FROM ONLY $id",
          )
          .then((value) => value!.first)
          .then(Account.fromMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SetAccount extends AsyncEvent<AsyncState> {
  const SetAccount({
    required this.balance,
    required this.relayId,
    required this.account,
  });
  final Account account;
  final String relayId;
  final double balance;
  String get _rawSQL => r'''
LET $id = SELECT VALUE id FROM ONLY created WHERE (in = $relayId and out=$accountId);
if ($id != NONE) {
  RETURN UPDATE ONLY $id SET balance=$balance;
} else {
  RETURN RELATE ONLY $relayId->created->$accountId UNIQUE SET balance=$balance;
};
''';
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      await SurrealConfig.client.query(_rawSQL, vars: {
        'accountId': account.id,
        'relayId': relayId,
        'balance': balance,
      }).then((value) => value!.last);
      emit(SuccessState(account.copyWith(balance: balance)));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class DeleteAccount extends AsyncEvent<AsyncState> {
  const DeleteAccount({
    required this.account,
  });
  final Account account;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
