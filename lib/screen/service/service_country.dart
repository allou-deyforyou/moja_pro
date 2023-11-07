import 'dart:async';

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
      final data = await SurrealConfig.client.select(Country.schema).then(Country.fromListMap);
      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
