import 'package:firebase_messaging/firebase_messaging.dart';

import '_service.dart';

class NotificationConfig {
  const NotificationConfig._();

  static String _getTopicFromLanguage(String language) {
    return 'moja_$language';
  }

  static Future<void> development() async {}

  static Future<void> production() async {}

  static Future<bool> enableNotifications([bool? skip]) async {
    final settings = await FirebaseConfig.firebaseMessaging.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        await disableNotifications();

        final languageCode = HiveLocalDB.locale?.languageCode;
        if (languageCode != null) {
          await Future.wait([
            FirebaseConfig.firebaseMessaging.subscribeToTopic(
              _getTopicFromLanguage(languageCode),
            ),
          ]);
        }

        return HiveLocalDB.notifications = true;
      default:
        if (skip == null) {
          await FirebaseConfig.firebaseMessaging.requestPermission();
          return enableNotifications(true);
        }
        return false;
    }
  }

  static Future<void> disableNotifications() async {
    final settings = await FirebaseConfig.firebaseMessaging.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        final languageCode = HiveLocalDB.locale?.languageCode;
        if (languageCode != null) {
          await Future.wait([
            FirebaseConfig.firebaseMessaging.unsubscribeFromTopic(
              _getTopicFromLanguage(languageCode),
            ),
          ]);
        }

        HiveLocalDB.notifications = false;
        break;
      default:
    }
  }
}
