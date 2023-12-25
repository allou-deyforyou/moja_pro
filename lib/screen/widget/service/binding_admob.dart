import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  const AdMobConfig._();

  static String? _choiceAdBanner;
  static String get choiceAdBanner => _choiceAdBanner!;

  static String? _homeInterstitialAd;
  static String get homeInterstitialAd => _homeInterstitialAd!;

  static Future<void> development() async {
    await MobileAds.instance.initialize();

    _choiceAdBanner = 'ca-app-pub-3940256099942544/6300978111';
    _homeInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  }

  static Future<void> production() async {
    await MobileAds.instance.initialize();

    _choiceAdBanner = 'ca-app-pub-3940256099942544/6300978111';
    _homeInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  }
}
