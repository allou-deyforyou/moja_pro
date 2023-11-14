import 'dart:async';
import 'dart:convert';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class GetAccount extends AsyncEvent<AsyncState> {
  const GetAccount({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('SELECT * FROM ONLY $id');
      final data = Account.fromMap(responses.first);
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
    this.account,
    this.relayId,
    this.name,
    this.balance,
  });
  final Account? account;

  final String? relayId;

  final String? name;
  final double? balance;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = account?.id ?? Account.schema;
      final values = {
        Account.nameKey: name,
        Account.balanceKey: balance,
      }
        ..removeWhere((key, value) => value == null)
        ..updateAll((key, value) => {key: jsonEncode(value)});
      final responses = await sql('INSERT INTO ONLY $id $values');
      final data = Relay.fromMap(responses.first);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
