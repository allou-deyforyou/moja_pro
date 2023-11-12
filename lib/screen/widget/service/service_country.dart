import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentCountryController => Singleton.instance(() => AsyncController<AsyncState>(const InitState()), Country.schema);

class SearchCountry extends AsyncEvent<AsyncState> {
  const SearchCountry({
    this.query,
  });
  final String? query;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final source = await sql('SELECT * FROM ${Country.schema}');
      final data = await compute(Country.fromListJson, source);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
