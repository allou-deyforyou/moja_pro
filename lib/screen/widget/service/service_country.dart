import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentCountry => singleton(AsyncController<AsyncState>(const InitState()), Country.schema);

class SelectCountry extends AsyncEvent<AsyncState> {
  const SelectCountry();

  static Future<List<Country>> _loadCountries(String path) async {
    final source = await rootBundle.loadString(path);
    return compute(Country.fromListJson, source);
  }

  static Future<List<Country>> _fetchCountries(String query) async {
    final responses = await sql(query);
    final List response = responses.first;
    return List.of(response.map((data) => Country.fromMap(data)));
  }

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final futures = await Future.wait([
        _loadCountries('assets/files/countries.json'),
        _fetchCountries('SELECT * FROM ${Country.schema}'),
      ]);
      final countriesLoaded = futures.first;
      final responsesFetched = futures.last;
      final data = List.of(responsesFetched.map((fetched) {
        final country = countriesLoaded.elementAt(countriesLoaded.indexOf(fetched));
        return country.copyWith(id: fetched.id);
      }));

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
