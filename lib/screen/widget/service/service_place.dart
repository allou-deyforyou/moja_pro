import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

Future<Iterable<dynamic>>? _searchPlaceResponses;
Future<List<Place>> searchPlaceByQuery({
  required (double, double) position,
  required String query,
}) async {
  try {
    final ok = await Future.microtask(() {
      _searchPlaceResponses?.ignore();
      if (query.trim().isEmpty) return true;
    });
    if (ok != null) return [];
    _searchPlaceResponses = sql('RETURN fn::search_place_by_query("$query", ${position.$2}, ${position.$1}, "fr");');
    final List response = (await _searchPlaceResponses!).first;
    return List.of(response.map((data) => Place.fromMap(data)!));
  } on TimeoutException {
    return [];
  } catch (error) {
    rethrow;
  }
}

class SearchPlaceEvent extends AsyncEvent<AsyncState> {
  const SearchPlaceEvent({
    required this.position,
  });
  final (double, double) position;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('RETURN fn::search_place_by_point(${position.$2}, ${position.$1}, "fr");');
      final List response = responses.first;
      final result = List.of(response.map((data) => Place.fromMap(data)!));
      if (result.isNotEmpty) {
        final place = result.first;
        final data = place.copyWith(
          position: place.position!.copyWith(
            coordinates: [position.$1, position.$2],
          ),
        );
        emit(SuccessState(data));
      } else {
        emit(FailureState(
          code: 'no-found',
          event: this,
        ));
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
