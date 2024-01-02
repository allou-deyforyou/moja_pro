import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

import '_service.dart';

class NotificationConfig {
  const NotificationConfig._();

  static Future<void> development() {
    return _initializeNotifications();
  }

  static Future<void> production() {
    return _initializeNotifications();
  }

  static String _getTopicFromLanguage(String language) {
    return 'moja_$language';
  }

  static Future<bool> enableNotifications([bool? skip]) async {
    final settings = await FirebaseConfig.firebaseMessaging.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        final languageCode = HiveLocalDB.locale?.languageCode;
        if (languageCode != null) {
          Future.wait([
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
          Future.wait([
            hideAvailabilityNotification(),
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

  static FlutterLocalNotificationsPlugin? _localNotifications;
  static FlutterLocalNotificationsPlugin get localNotifications => _localNotifications!;

  static Future<void> _initializeNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.initialize(initializationSettings);

    _localNotifications = notificationsPlugin;
  }

  static Future<void> showAvailabilityNotification({
    required String title,
    required String body,
    bool fixed = false,
    DateTime? dateTime,
  }) async {
    if (!(HiveLocalDB.notifications ?? true)) return;

    final androidDetails = AndroidNotificationDetails(
      "availability_id",
      "user's Availability",
      channelDescription: "Notification to show user's Availability",
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
      ongoing: fixed,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    if (dateTime != null) {
      final scheduledDate = tz.TZDateTime.from(
        dateTime,
        tz.getLocation(HiveLocalDB.currentTimeZone),
      );

      return localNotifications.zonedSchedule(
        0,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    await hideAvailabilityNotification();

    return localNotifications.show(0, title, body, notificationDetails);
  }

  static Future<void> hideAvailabilityNotification() {
    return localNotifications.cancel(0);
  }
}
