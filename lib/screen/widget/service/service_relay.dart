import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SelectRelay extends AsyncEvent<AsyncState> {
  const SelectRelay({
    required this.userId,
  });
  final String userId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final filters = 'WHERE <-works<-(${User.schema} WHERE ${User.idKey} = $userId)';
      final responses = await sql('SELECT * FROM ${Relay.schema} $filters');
      final data = Relay.fromListMap(responses.first);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class GetRelay extends AsyncEvent<AsyncState> {
  const GetRelay({
    required this.id,
  });
  final String id;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('SELECT * FROM ONLY $id');
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

class SetRelay extends AsyncEvent<AsyncState> {
  const SetRelay({
    this.relay,
    this.name,
    this.image,
    this.location,
    this.availability,
    this.contacts,
    this.workdays,
  });
  final Relay? relay;

  final String? name;
  final String? image;
  final Place? location;
  final bool? availability;
  final List<String>? contacts;
  final List<Weekday>? workdays;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = relay?.id ?? Relay.schema;
      final values = {
        Relay.nameKey: name,
        Relay.imageKey: image,
        Relay.contactsKey: contacts,
        Relay.availabilityKey: availability,
        Relay.locationKey: location?.toMap(),
      }..removeWhere((key, value) => value == null);
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
