import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

Future<List<Place>> searchPlaceByQuery({
  required Point position,
  required String query,
}) async {
  final responses = await sql('RETURN fn::search_place_by_query("$query", ${position.latitude}, ${position.longitude}, "fr");');
  final List response = responses.first;
  return List.of(response.map((data) => Place.fromMap(data)));
}

class SearchPlaceEvent extends AsyncEvent<AsyncState> {
  const SearchPlaceEvent({
    required this.position,
    this.query,
  });
  final Point position;
  final String? query;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (query != null) {
        final data = await searchPlaceByQuery(position: position, query: query!);
        emit(SuccessState(data));
      } else {
        final responses = await sql('RETURN fn::search_place_by_point(${position.latitude}, ${position.longitude}, "fr");');
        final List response = responses.first;
        final data = List.of(response.map((data) => Place.fromMap(data)));
        emit(SuccessState(data));
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
