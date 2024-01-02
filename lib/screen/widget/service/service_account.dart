import 'dart:async';

import 'package:listenable_tools/listenable_tools.dart';

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

      await SaveAccountEvent(accounts: [data]).handle(emit);

      emit(SuccessState(data));

      FirebaseConfig.firebaseAnalytics.logEvent(
        name: 'set-account-balance',
        parameters: {
          Account.idKey: data.id,
          Account.nameKey: data.name,
          Account.balanceKey: data.balance,
        },
      );
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SaveAccountEvent extends AsyncEvent<AsyncState> {
  const SaveAccountEvent({
    required this.accounts,
  });
  final List<Account> accounts;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await IsarLocalDB.isar.writeTxn(() async {
        return IsarLocalDB.isar.accounts.putAll(accounts);
      });

      emit(SuccessState(accounts));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
