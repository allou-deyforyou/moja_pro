import 'dart:developer';

import 'package:flutter/foundation.dart';

import '_service.dart';

class RemoteConfig {
  const RemoteConfig._();

  static Future<void> initializeRemoteConfig() async {
    // Paramètres par défaut
    final defaults = <String, dynamic>{
      policeSupportKey: '100',
      emailSupportKey: 'support@moja.com',
      whatsappSupportKey: '+225 0749414602',
      appLinkKey: switch (defaultTargetPlatform) {
        TargetPlatform.android => 'https://play.google.com/store/apps/details?id=com.moja.moja',
        TargetPlatform.iOS => 'https://apps.apple.com/ci/app/moja?id=com.moja.moja',
        _ => throw 'Unsupported Platform',
      },
    };

    await FirebaseConfig.firebaseRemoteConfig.setDefaults(defaults);

    await fetchAndActivate();
  }

  static Future<void> fetchAndActivate() async {
    try {
      await FirebaseConfig.firebaseRemoteConfig.fetchAndActivate();
    } catch (e) {
      log('[FirebaseRemoteConfig] Failed to load: $e');
    }
  }

  static const whatsappSupportKey = 'whatsapp_support';
  static Uri get whatsappSupport => Uri(
        host: 'wa.me',
        scheme: 'https',
        path: FirebaseConfig.firebaseRemoteConfig.getString(whatsappSupportKey),
      );

  static const emailSupportKey = 'email_support';
  static Uri get emailSupport => Uri(
        scheme: 'mailto',
        path: FirebaseConfig.firebaseRemoteConfig.getString(emailSupportKey),
      );

  static const policeSupportKey = 'police_support';
  static Uri get policeSupport => Uri(
        scheme: 'tel',
        path: FirebaseConfig.firebaseRemoteConfig.getString(policeSupportKey),
      );

  static const appLinkKey = 'app_link';
  static String get appLink => FirebaseConfig.firebaseRemoteConfig.getString(appLinkKey);
}
