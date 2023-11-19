import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SearchPlace extends AsyncEvent<AsyncState> {
  const SearchPlace({
    required this.position,
    this.query,
  });
  final Point position;
  final String? query;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('SELECT * FROM ${Place.schema}');
      final data = List.of(responses.first.map((data) => Place.fromMap(data)));
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
