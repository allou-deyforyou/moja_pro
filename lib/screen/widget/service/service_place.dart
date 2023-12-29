import 'dart:async';

import 'package:listenable_tools/listenable_tools.dart';

import '_service.dart';

Future<Iterable<dynamic>> _response = Future.value([]);
Future<List<Place>> searchPlace({
  required ({double longitude, double latitude}) position,
  String query = '',
}) async {
  try {
    await Future.microtask(_response.ignore);
    _response = sql('fn::search_place("$query", ${position.longitude}, ${position.latitude});');
    final List response = await _response.then((value) => value.first);
    return List.of(response.map((data) => Place.fromMap(data)!));
  } on TimeoutException {
    return List.empty();
  } catch (error) {
    rethrow;
  }
}

class SearchPlaceEvent extends AsyncEvent<AsyncState> {
  const SearchPlaceEvent({
    this.query = '',
    required this.position,
  });
  final String query;
  final ({double longitude, double latitude}) position;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final data = await searchPlace(position: position, query: query);
      if (data.isNotEmpty) {
        if (query.isNotEmpty) {
          emit(SuccessState(data, event: this));
        } else {
          final place = data.first;
          final item = place.copyWith(
            position: place.position!.copyWith(coordinates: [
              position.longitude,
              position.latitude,
            ]),
          );
          emit(SuccessState(item, event: this));
        }
      } else {
        emit(FailureState(
          'no-record',
          event: this,
        ));
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
