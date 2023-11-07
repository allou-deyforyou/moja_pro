import 'dart:convert';

import 'package:equatable/equatable.dart';

class Weekday extends Equatable {
  const Weekday({
    required this.id,
    this.endTime,
    this.startTime,
  });

  static const List<Weekday> defaultWeekdays = [
    Weekday(id: DateTime.monday),
    Weekday(id: DateTime.tuesday),
    Weekday(id: DateTime.thursday),
    Weekday(id: DateTime.wednesday),
    Weekday(id: DateTime.friday),
    Weekday(id: DateTime.saturday),
    Weekday(id: DateTime.sunday),
  ];

  static const String schema = 'weekday';

  static const String idKey = 'id';
  static const String endTimeKey = 'end_time';
  static const String startTimeKey = 'start_time';

  final int id;
  final DateTime? endTime;
  final DateTime? startTime;

  @override
  List<Object?> get props {
    return [
      id,
      startTime,
      endTime,
    ];
  }

  Weekday copyWith({
    int? id,
    DateTime? endTime,
    DateTime? startTime,
  }) {
    return Weekday(
      id: id ?? this.id,
      endTime: endTime ?? this.endTime,
      startTime: startTime ?? this.startTime,
    );
  }

  Weekday clone() {
    return copyWith(
      startTime: startTime,
      endTime: endTime,
      id: id,
    );
  }

  static Weekday fromMap(dynamic data) {
    return Weekday(
      id: data[idKey],
      endTime: DateTime.parse(data[endTimeKey]),
      startTime: DateTime.parse(data[startTimeKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      endTimeKey: endTime?.toString(),
      startTimeKey: startTime?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  static List<Weekday> fromListMap(dynamic data) {
    return List.of((data as List).map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Weekday> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Weekday? fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Weekday?> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Weekday> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
