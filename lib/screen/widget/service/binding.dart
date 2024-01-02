import 'package:service_tools/service_tools.dart';

import '_service.dart';

class MyService extends FlutterService {
  const MyService();

  @override
  Future<void> developmentBinding() {
    return Future.wait([
      NotificationConfig.development(),
      FirebaseConfig.development(),
      SurrealConfig.development(),
      HiveLocalDB.development(),
      IsarLocalDB.development(),
      AdMobConfig.development(),
    ]);
  }

  @override
  Future<void> productionBinding() {
    return Future.wait([
      NotificationConfig.production(),
      FirebaseConfig.production(),
      SurrealConfig.production(),
      HiveLocalDB.production(),
      IsarLocalDB.production(),
      AdMobConfig.production(),
    ]);
  }

  @override
  Future<void> afterBinding() {
    return Future.wait([
      HiveLocalDB.showInAppReview(),
    ]);
  }
}
