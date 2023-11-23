import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SetAccountEvent extends AsyncEvent<AsyncState> {
  const SetAccountEvent({
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

      final currentUser = DatabaseConfig.currentUser;
      if (currentUser != null) {
        final relay = currentUser.relays!.first;
        final accounts = relay.accounts!;
        final index = accounts.indexOf(data);
        accounts[index] = data;
        DatabaseConfig.currentUser = currentUser.copyWith(relays: [
          relay.copyWith(accounts: accounts),
        ]);
      }

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
