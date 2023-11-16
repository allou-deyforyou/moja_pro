import 'dart:async';

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
    required this.account,
    required this.balance,
    required this.relay,
  });
  final Account account;
  final Relay relay;

  final double balance;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final relayId = relay.id;
      final accountId = account.id;

      final accountQuery = 'LET \$created_id = SELECT VALUE id FROM ONLY created WHERE (in = $relayId and out=$accountId);';
      final accountUpdate = 'RETURN UPDATE ONLY \$created_id SET balance=$balance;';
      final accountCreate = 'RETURN RELATE ONLY $relayId->created->$accountId SET balance=$balance;';
      await sql('$accountQuery RETURN IF (\$created_id != NONE) {$accountUpdate} ELSE {$accountCreate};');
      final data = account.copyWith(balance: balance);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
