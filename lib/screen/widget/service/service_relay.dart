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
      final data = List.of(response.map((data) => Relay.fromMap(data)!));

      await SaveRelayEvent(relays: data).handle(emit);

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
      final data = Relay.fromMap(responses.first)!;

      await SaveRelayEvent(relays: [data]).handle(emit);

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
  final List<String>? contacts;
  final RelayAvailability? availability;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = relay.id;
      final values = {
        Relay.nameKey: name?.json(),
        Relay.imageKey: image?.json(),
        Relay.locationKey: location?.toSurreal(),
        Relay.availabilityKey: availability?.toString(),
        Relay.contactsKey: contacts?.map((e) => e.json()),
      }..removeWhere((key, value) => value == null);

      final responses = await sql('UPDATE ONLY $id MERGE $values;');

      final result = Relay.fromMap(responses.first)!;
      final data = result.copyWith(accounts: relay.accounts);

      await SaveRelayEvent(relays: [data]).handle(emit);

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SaveRelayEvent extends AsyncEvent<AsyncState> {
  const SaveRelayEvent({
    required this.relays,
  });
  final List<Relay> relays;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await IsarLocalDB.isar.writeTxn(() async {
        return IsarLocalDB.isar.relays.putAll(relays);
      });
      await Future.wait([
        SaveAccountEvent(
          accounts: List.of(relays.expand((item) => item.accounts)),
        ).handle(emit),
      ]);
      await IsarLocalDB.isar.writeTxn(() async {
        return Future.wait(relays.map((item) => item.accounts.save()));
      });

      emit(SuccessState(relays));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
