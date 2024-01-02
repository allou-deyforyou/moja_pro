import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const name = 'home';
  static const path = '/';

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (await Permission.locationWhenInUse.isGranted) {
      if (currentUser.value != null) {
        return null;
      }
      return AuthScreen.path;
    }
    return OnBoardingScreen.path;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
  late Relay _currentRelay;

  DateTime? _relayAvailability;

  late List<Account> _relayAccounts;

  Timer? _availabilityTimer;

  Timer? _interstitialAdTimer;
  late Duration _interstitialAdTimeout;
  InterstitialAd? _interstitialAd;

  BannerAd? _bannerAd;
  late ValueNotifier<bool> _bannerAdLoaded;

  bool _enabledAvailability([DateTime? availability]) {
    availability ??= _relayAvailability;
    return availability != null && availability.isAfter(DateTime.now());
  }

  void _loadInterstitialAd() {
    _interstitialAdTimer = Timer(_interstitialAdTimeout, () async {
      if (_interstitialAd == null) {
        InterstitialAd.load(
          request: const AdRequest(),
          adUnitId: AdMobConfig.homeInterstitialAd,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdFailedToLoad: (err) {},
            onAdLoaded: (ad) {
              _interstitialAd = ad;
            },
          ),
        );

        if (_interstitialAdTimeout <= const Duration(minutes: 5)) {
          _interstitialAdTimeout += const Duration(minutes: 1);
        }
      }

      _loadInterstitialAd();
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: customBannerAd,
      request: const AdRequest(),
      adUnitId: AdMobConfig.choiceAdBanner,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, err) => ad.dispose(),
        onAdLoaded: (ad) {
          _bannerAdLoaded.value = true;

          FirebaseConfig.firebaseAnalytics.logAdImpression(
            adUnitName: ad.adUnitId,
            adFormat: 'BannerAd',
          );
        },
      ),
    )..load();
  }

  void _showDisabledLocationModal() async {
    final data = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return const HomeDisabledLocationModal();
      },
    );
    if (data != null && data) {
      _openLocationScreen();
    }
  }

  void _openMenu() {
    context.pushNamed(HomeMenuScreen.name);
  }

  Future<void> _openLocationScreen() {
    return context.pushNamed(ProfileLocationScreen.name, extra: {
      ProfileLocationScreen.relayKey: _currentRelay,
    });
  }

  void _showAvailabilityNotification(DateTime? availability) {
    if (mounted) {
      if (availability != null && _enabledAvailability(availability)) {
        NotificationConfig.showAvailabilityNotification(
          fixed: true,
          title: "${_currentRelay.name} est en ligne 🤗 !",
          body: "Votre point relais reste visible jusqu'a ${availability.hour.toString().padLeft(2, '0')}h.",
        );
        NotificationConfig.showAvailabilityNotification(
          dateTime: availability,
          title: "${_currentRelay.name} est hors ligne !",
          body: "Votre point relais a été fermé.",
        );
      } else {
        NotificationConfig.showAvailabilityNotification(
          title: "${_currentRelay.name} est hors ligne !",
          body: "Votre point relais a été fermé.",
        );
      }
    }
  }

  void _onAvailableChanged(bool value) {
    _setRelay(
      availability: switch (value) {
        true => RelayAvailability.enabled,
        _ => RelayAvailability.disabled,
      },
    );
  }

  Future<Account?> _onAccountTap(Account account) async {
    final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
      HomeAccountScreen.relayKey: _currentRelay,
      HomeAccountScreen.accountKey: account,
    });

    if (data != null) {
      await _interstitialAd?.show();
      FirebaseConfig.firebaseAnalytics.logAdImpression(
        adUnitName: _interstitialAd?.adUnitId,
        adFormat: 'interstitialAd',
      );
      _interstitialAd = null;

      return data;
    }
    return null;
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;
  StreamSubscription? _relaySubscription;

  bool _canRebuildRelay(AsyncState previousState, AsyncState currentState) {
    if (currentState is FailureState) return true;
    return previousState is SuccessState<Relay> && currentState is SuccessState<Relay>;
  }

  void _listenRelayState(BuildContext context, AsyncState state) async {
    if (state is InitState) {
      final user = currentUser.value!;

      _currentRelay = user.relays.first;
      _relayAccounts = _currentRelay.accounts.toList();

      if (_currentRelay.location == null) {
        await _openLocationScreen();
      }

      WidgetsBinding.instance.endOfFrame.whenComplete(() {
        _showAvailabilityNotification(_currentRelay.availability);
      });

      _loadRelay();
    } else if (state case SuccessState<StreamSubscription>(:final data)) {
      _relaySubscription = data;
    } else if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      _relayAccounts = _currentRelay.accounts.toList();

      if (_relayAvailability != _currentRelay.availability) {
        _showAvailabilityNotification(_currentRelay.availability);
      }
      _relayAvailability = _currentRelay.availability?.toLocal();
    } else if (state case FailureState<String>(:final data)) {
      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    } else if (state case FailureState<String>(:final data)) {
      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _loadRelay() {
    return _relayController.run(LoadRelayEvent(
      relayId: _currentRelay.id,
      listen: true,
    ));
  }

  Future<void> _getRelay() {
    return _relayController.run(GetRelayEvent(
      id: _currentRelay.id,
    ));
  }

  Future<void> _setRelay({required RelayAvailability availability}) {
    return _relayController.run(SetRelayEvent(
      availability: availability,
      relay: _currentRelay,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _interstitialAdTimeout = Duration.zero;
    _loadInterstitialAd();

    _bannerAdLoaded = ValueNotifier(false);
    _loadBannerAd();

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _interstitialAdTimer?.cancel();
    _availabilityTimer?.cancel();

    /// RelayService
    _relaySubscription?.cancel();
    _relayController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _bannerAdLoaded,
        builder: (context, loaded, child) {
          return CustomBannerAdWidget(
            loaded: loaded,
            ad: _bannerAd!,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _getRelay,
        child: CustomScrollView(
          slivers: [
            HomeSliverAppBar(
              leading: HomeBarsButton(
                onPressed: _openMenu,
              ),
              trailing: ControllerBuilder(
                controller: _relayController,
                canRebuild: _canRebuildRelay,
                builder: (context, state, child) {
                  bool active = _enabledAvailability();
                  return StatefulBuilder(
                    builder: (context, setState) {
                      void onChanged(bool value) {
                        if (_currentRelay.location == null) {
                          return _showDisabledLocationModal();
                        }
                        setState(() => active = value);
                        _onAvailableChanged(value);
                      }

                      return HomeAvailableSwitch(
                        onChanged: onChanged,
                        value: active,
                      );
                    },
                  );
                },
              ),
            ),
            const SliverPadding(padding: kMaterialListPadding),
            ControllerBuilder(
              autoListen: true,
              listener: _listenRelayState,
              canRebuild: _canRebuildRelay,
              controller: _relayController,
              builder: (context, state, child) {
                _relayAccounts.sort(Account.accountSort);
                return HomeAccountSliverGridView(
                  itemCount: _relayAccounts.length,
                  itemBuilder: (context, index) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        final item = _relayAccounts[index];
                        void onPressed() async {
                          final data = await _onAccountTap(item);
                          if (data != null) setState(() => _relayAccounts[index] = data);
                        }

                        return HomeAccountCard(
                          onPressed: onPressed,
                          amount: item.balance,
                          name: item.name,
                          cash: item.cash,
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: kMaterialListPadding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
