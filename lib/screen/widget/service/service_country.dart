import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentCountry => singleton(AsyncController<AsyncState>(const InitState()), Country.schema);

class SelectCountry extends AsyncEvent<AsyncState> {
  const SelectCountry();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final responses = await sql('SELECT * FROM ${Country.schema}');
      final List response = responses.first;
      final data = List.of(response.map((data) => Country.fromMap(data)));
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
