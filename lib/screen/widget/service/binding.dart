import 'package:service_tools/service_tools.dart';

import '_service.dart';

class MyService extends FlutterService {
  const MyService();

  @override
  Future<void> developmentBinding() {
    return Future.wait([
      FirebaseConfig.development(),
      SurrealConfig.development(),
      HiveLocalDB.development(),
      IsarLocalDB.development(),
    ]);
  }

  @override
  Future<void> productionBinding() {
    return Future.wait([
      FirebaseConfig.production(),
      SurrealConfig.production(),
      HiveLocalDB.production(),
      IsarLocalDB.production(),
    ]);
  }
}
