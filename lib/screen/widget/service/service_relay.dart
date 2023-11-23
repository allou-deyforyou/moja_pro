import 'dart:async';
import 'dart:convert';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class GetRelayEvent extends AsyncEvent<AsyncState> {
  const GetRelayEvent({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      const accountQuery = '(SELECT id, name, array::first(<-created.balance) as balance FROM ${Account.schema} PARALLEL) AS accounts';
      final responses = await sql('SELECT *, $accountQuery FROM ONLY $id');
      final data = Relay.fromMap(responses.first);
      final currentUser = DatabaseConfig.currentUser;
      if (currentUser != null) DatabaseConfig.currentUser = currentUser.copyWith(relays: [data]);
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
        Relay.nameKey: name,
        Relay.imageKey: image,
        Relay.contactsKey: contacts,
        Relay.locationKey: location?.toMap(),
      }
        ..removeWhere((key, value) => value == null)
        ..updateAll((key, value) => jsonEncode(value));

      values[Relay.availabilityKey] = switch (availability) {
        true => 'time::now()',
        false => 'NONE',
        _ => null,
      };
      values.removeWhere((key, value) => value == null);

      final responses = await sql('UPDATE ONLY $id MERGE $values;');
      final result = Relay.fromMap(responses.first);
      final data = result.copyWith(
        accounts: relay.accounts,
      );
      final currentUser = DatabaseConfig.currentUser;
      if (currentUser != null) DatabaseConfig.currentUser = currentUser.copyWith(relays: [data]);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
