import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:archive/archive.dart';
import 'package:equatable/equatable.dart';

import '_schema.dart';

part 'schema_file.g.dart';

@Collection(inheritance: false)
class File extends Equatable {
  const File({
    required this.id,
    required this.data,
    required this.record,
    this.createdAt,
  });

  static const String schema = 'file';

  static const String idKey = 'id';
  static const String dataKey = 'data';
  static const String recordKey = 'owner';
  static const String createdAtKey = 'created_at';

  Id get isarId => id.fastHash;

  final String id;
  final String record;
  final List<int> data;
  final DateTime? createdAt;

  @ignore
  @override
  List<Object?> get props {
    return [
      id,
      data,
      record,
      createdAt,
    ];
  }

  File copyWith({
    String? id,
    String? record,
    List<int>? data,
    DateTime? createdAt,
  }) {
    return File(
      id: id ?? this.id,
      data: data ?? this.data,
      record: record ?? this.record,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  File clone() {
    return copyWith(
      id: id,
      data: data,
      record: record,
      createdAt: createdAt,
    );
  }

  static File? fromMap(dynamic data) {
    if (data == null) return null;
    return File(
      id: data[idKey],
      record: data[recordKey],
      data: GZipDecoder().decodeBytes(data[dataKey]),
      createdAt: DateTime.tryParse(data[createdAtKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      dataKey: data,
      recordKey: record,
      createdAtKey: createdAt?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      dataKey: data,
      recordKey: record.json(),
      createdAtKey: createdAt?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  static File fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
