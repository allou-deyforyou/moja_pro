import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SearchPlaceByQuery extends AsyncEvent<AsyncState> {
  const SearchPlaceByQuery({
    required this.query,
    required this.position,
  });
  final String query;
  final (double, double) position;

  static const _rawQuery = r'''
RETURN fn::search_place_by_point($query, $latitude, $longitude, $language);
''';

  static Future<Object>? _response;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      scheduleMicrotask(() {
        _response?.timeout(Duration.zero);
        _response = null;
      });
      _response = SurrealConfig.client.query(_rawQuery, vars: {
        'longitude': position.$2,
        'latitude': position.$1,
        'language': 'fr',
        'query': query,
      }).then((value) => value!.first!);
      final data = await _response!.then(Place.fromListMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SearchPlaceByPosition extends AsyncEvent<AsyncState> {
  const SearchPlaceByPosition({
    required this.position,
  });
  final (double, double) position;

  static const _rawQuery = r'''
RETURN fn::search_place_by_point($latitude, $longitude, $language);
''';

  static Future<Object>? _response;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      await _response?.timeout(Duration.zero);
      // await Future.microtask(() {
      _response = SurrealConfig.client.query(_rawQuery, vars: {
        'longitude': position.$2,
        'latitude': position.$1,
        'language': 'fr',
      }).then((value) => value!.first!);
      // });
      final data = await _response!.then(Place.fromListMap);
      emit(SuccessState(data.first.copyWith(
        position: position,
      )));
    } on TimeoutException {
      _response = null;
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
