import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

class SetFileEvent extends AsyncEvent<AsyncState> {
  const SetFileEvent({
    this.file,
    required this.record,
    required this.bufferData,
  });
  final File? file;

  final String record;
  final Uint8List bufferData;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final values = {
        File.recordKey: record,
        File.dataKey: GZipEncoder().encode(bufferData),
      };

      final query = 'INSERT INTO ${file?.id ?? File.schema} $values;';
      final responses = await sql(Stream.value(query.codeUnits), headers: {
        Headers.contentLengthHeader: query.length,
      });
      final List response = responses.first;
      final data = response.map<File>((e) => File.fromMap(e)!).first;

      await SaveFileEvent(files: [data]).handle(emit);

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class LoadFileEvent extends AsyncEvent<AsyncState> {
  const LoadFileEvent({
    required this.fileId,
    this.listen = false,
  });
  final bool listen;
  final String fileId;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (listen) {
        final stream = IsarLocalDB.isar.files.watchObject(
          fireImmediately: true,
          fileId.fastHash,
        );
        return stream.forEach((data) {
          if (data != null) {
            emit(SuccessState(data));
          } else {
            emit(FailureState(
              code: 'no-record',
              event: this,
            ));
          }
        });
      } else {
        final data = await IsarLocalDB.isar.files.get(
          fileId.fastHash,
        );
        if (data != null) {
          emit(SuccessState(data));
        } else {
          emit(FailureState(
            code: 'no-record',
            event: this,
          ));
        }
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SaveFileEvent extends AsyncEvent<AsyncState> {
  const SaveFileEvent({
    required this.files,
  });
  final List<File> files;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await IsarLocalDB.isar.writeTxn(() async {
        return IsarLocalDB.isar.files.putAll(files);
      });

      emit(SuccessState(files));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
