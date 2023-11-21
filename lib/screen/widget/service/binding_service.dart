import 'package:service_tools/service_tools.dart';

import '_service.dart';

class MyService extends FlutterService {
  const MyService();

  @override
  Future<void> developmentBinding() {
    return Future.wait([
      RepositoryConfig.development(),
      FirebaseConfig.development(),
      DatabaseConfig.development(),
    ]);
  }

  @override
  Future<void> productionBinding() {
    return Future.wait([
      RepositoryConfig.production(),
      FirebaseConfig.production(),
      DatabaseConfig.production(),
    ]);
  }
}
