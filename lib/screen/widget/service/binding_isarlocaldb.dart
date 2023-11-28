import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '_service.dart';

class IsarLocalDB {
  const IsarLocalDB._();

  static Isar? _isar;
  static Isar get isar => _isar!;

  static Future<void> development() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserSchema, RelaySchema, AccountSchema, CountrySchema],
      directory: dir.path,
      name: 'development',
    );
  }

  static Future<void> production() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserSchema, RelaySchema, AccountSchema, CountrySchema],
      directory: dir.path,
      name: 'production',
    );
  }
}
