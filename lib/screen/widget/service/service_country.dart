import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentCountry => singleton(AsyncController<AsyncState>(const InitState()), Country.schema);

class SearchCountry extends AsyncEvent<AsyncState> {
  const SearchCountry();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final response = await sql('SELECT * FROM ${Country.schema}');
      final data = Country.fromListMap(response.first);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
