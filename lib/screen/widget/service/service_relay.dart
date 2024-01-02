import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

      const accountSelect = '(SELECT *, array::first(<-created.balance) as balance FROM ${Account.schema}) AS accounts';
      final relayFilters = 'WHERE <-worked<-(${User.schema} WHERE ${User.idKey} = $userId)';
      final responses = await sql('SELECT *, $accountSelect FROM ${Relay.schema} $relayFilters');

      final List response = responses.first;
      final data = List.of(response.map((data) => Relay.fromMap(data)!));

      await SaveRelayEvent(relays: data).handle(emit);

      emit(SuccessState(data, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
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
      const accountSelect = 'SELECT *, array::first(<-created.balance) as balance FROM ${Account.schema} PARALLEL';
      final responses = await sql('SELECT *, ($accountSelect) AS ${Account.schema}s FROM ONLY $id');
      final data = Relay.fromMap(responses.first)!;

      await SaveRelayEvent(relays: [data]).handle(emit);

      emit(SuccessState(data, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SetRelayEvent extends AsyncEvent<AsyncState> {
  const SetRelayEvent({
    required this.relay,
    this.name,
    this.rawImage,
    this.location,
    this.availability,
    this.contacts,
  });
  final Relay relay;

  final String? name;
  final Place? location;
  final Uint8List? rawImage;
  final List<String>? contacts;
  final RelayAvailability? availability;

  Future<Uint8List> _compressImage(Uint8List data) {
    return FlutterImageCompress.compressWithList(
      format: CompressFormat.png,
      rawImage!,
    );
  }

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final id = relay.id;

      String? image;
      if (rawImage != null) {
        final storage = FirebaseConfig.firebaseStorage.ref(
          '${Relay.schema}/$id.png',
        );
        await storage.putData(
          await _compressImage(rawImage!),
          SettableMetadata(contentType: "image/png"),
        );
        image = await storage.getDownloadURL();
      }

      final values = {
        Relay.nameKey: name?.json(),
        Relay.imageKey: image?.json(),
        Relay.locationKey: location?.toSurreal(),
        Relay.availabilityKey: availability?.toString(),
        Relay.contactsKey: contacts?.map((e) => e.json()).toList(),
      }..removeWhere((key, value) => value == null);

      final responses = await sql('UPDATE ONLY $id MERGE $values;');

      final result = Relay.fromMap(responses.first)!;
      final data = result.copyWith(accounts: relay.accounts);

      await SaveRelayEvent(relays: [data]).handle(emit);

      emit(SuccessState(data, event: this));

      if (rawImage != null) {
        FirebaseConfig.firebaseAnalytics.logEvent(
          name: 'set-relay-image',
          parameters: {
            Relay.idKey: data.id,
            Relay.nameKey: data.name,
          },
        );
      }
      if (availability != null) {
        FirebaseConfig.firebaseAnalytics.logEvent(
          name: 'set-relay-availability',
          parameters: {
            Relay.idKey: data.id,
            Relay.nameKey: data.name,
            Relay.availabilityKey: data.availability.toString(),
          },
        );
      }
      if (location != null) {
        FirebaseConfig.firebaseAnalytics.logEvent(
          name: 'set-relay-location',
          parameters: {
            Relay.idKey: data.id,
            Relay.nameKey: data.name,
            Relay.availabilityKey: (data.location?.title).toString(),
          },
        );
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class LoadRelayEvent extends AsyncEvent<AsyncState> {
  const LoadRelayEvent({
    required this.relayId,
    this.listen = false,
  });
  final bool listen;
  final String relayId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (listen) {
        final stream = IsarLocalDB.isar.relays.watchObject(
          fireImmediately: true,
          relayId.fastHash,
        );
        final subscription = stream.listen((data) {
          if (data != null) {
            emit(SuccessState(data, event: this));
          } else {
            emit(FailureState(
              'no-record',
              event: this,
            ));
          }
        });
        emit(SuccessState(subscription, event: this));
      } else {
        final data = await IsarLocalDB.isar.relays.get(
          relayId.fastHash,
        );
        if (data != null) {
          emit(SuccessState(data, event: this));
        } else {
          emit(FailureState(
            'no-record',
            event: this,
          ));
        }
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
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
      await IsarLocalDB.isar.writeTxn(() {
        return Future.wait(relays.map((item) => item.accounts.save()));
      });

      emit(SuccessState(relays, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
