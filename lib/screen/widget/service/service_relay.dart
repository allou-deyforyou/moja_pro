import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SelectRelayEvent extends AsyncEvent<AsyncState> {
  const SelectRelayEvent({
    required this.userId,
  });
  final String userId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      const accountSelect = '(SELECT id, name, array::first(<-created.balance) as balance FROM ${Account.schema}) AS accounts';
      final relayFilters = 'WHERE <-works<-(${User.schema} WHERE ${User.idKey} = $userId)';
      final responses = await sql('SELECT *, $accountSelect FROM ${Relay.schema} $relayFilters');

      final List response = responses.first;
      final data = List.of(response.map((data) => Relay.fromMap(data)));
      DatabaseConfig.relays = data;
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class GetRelayEvent extends AsyncEvent<AsyncState> {
  const GetRelayEvent({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      const accountSelect = 'SELECT id, name, array::first(<-created.balance) as balance FROM ${Account.schema} PARALLEL';
      final responses = await sql('SELECT *, ($accountSelect) AS ${Account.schema}s FROM ONLY $id');
      final data = Relay.fromMap(responses.first);
      DatabaseConfig.relays = [data];
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SetRelayEvent extends AsyncEvent<AsyncState> {
  const SetRelayEvent({
    required this.relay,
    this.name,
    this.image,
    this.location,
    this.availability,
    this.contacts,
  });
  final Relay relay;

  final String? name;
  final String? image;
  final Place? location;
  final bool? availability;
  final List<String>? contacts;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = relay.id;
      final values = {
        Relay.nameKey: name?.json(),
        Relay.imageKey: image?.json(),
        Relay.locationKey: location?.toSurreal(),
        Relay.contactsKey: contacts?.map((e) => e.json()),
        Relay.availabilityKey: switch (availability) {
          true => 'time::now()',
          false => 'NONE',
          _ => null,
        },
      }..removeWhere((key, value) => value == null);

      final responses = await sql('UPDATE ONLY $id MERGE $values;');

      final result = Relay.fromMap(responses.first);
      final data = result.copyWith(accounts: relay.accounts);
      DatabaseConfig.relays = [data];
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
