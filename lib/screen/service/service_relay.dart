import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SearchRelay extends AsyncEvent<AsyncState> {
  const SearchRelay({
    this.live = false,
    required this.userId,
    this.ids,
  });
  final bool live;
  final String? userId;
  final List<String>? ids;

  String get _rawSQL => r'''
SELECT
  *,
  (SELECT *, array::first(<-(has WHERE in = $parent.id).amount) as amount FROM account) as accounts 
FROM relay WHERE <-works<-(user WHERE id = $userId) PARALLEL;
''';
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client
          .query(_rawSQL, vars: {
            'userId': userId,
          })
          .then((value) => value!.first)
          .then(Relay.fromListMap);
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
    this.live = false,
    required this.id,
  });
  final bool live;
  final String id;
  String get _rawSQL => r'''
SELECT
    *,
    (SELECT id, name, array::first(<-created.balance) as balance FROM account)
  as accounts FROM ONLY $id;
''';
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client.query(_rawSQL, vars: {
        'id': id,
      }).then(Relay.fromListMap);
      emit(SuccessState(data.first));
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
      final data = await SurrealConfig.client.insert(relay?.name ?? Relay.schema, data: {
        Relay.nameKey: name,
        Relay.imageKey: image,
        Relay.contactsKey: contacts,
        Relay.availabilityKey: availability,
        Relay.locationKey: location?.toMap(),
      }).then(Relay.fromMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class DeleteRelay extends AsyncEvent<AsyncState> {
  const DeleteRelay({
    required this.relay,
  });
  final Relay relay;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await SurrealConfig.client.delete(relay.name).then(Relay.fromMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
