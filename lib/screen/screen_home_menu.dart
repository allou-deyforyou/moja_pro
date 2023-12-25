import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});
  static const name = 'home-menu';
  static const path = 'menu';
  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  /// Assets
  late User _currentUser;
  Stream<bool?>? _notificationsStream;
  bool? _currentNotifications;

  Stream<ThemeMode>? _themeModeStream;
  ThemeMode? _currentThemeMode;

  Stream<Locale?>? _localeStream;
  Locale? _currentLocale;

  void _openProfileScreen() {
    context.pushNamed(ProfileScreen.name);
  }

  void _openAuthScreen() {
    context.pushNamed(AuthScreen.name, extra: {
      AuthScreen.currentUserKey: _currentUser,
    });
  }

  void _onNotifsTaped(bool active) async {
    if (active) {
      final enabled = await NotificationConfig.enableNotifications();
      if (!enabled) _openNotifsModal();
    } else {
      NotificationConfig.disableNotifications();
    }
  }

  void _openNotifsModal() async {
    final data = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return const HomeMenuNotifisModal();
      },
    );
    if (data != null) {
      openAppSettings();
    }
  }

  VoidCallback _openThemeModal(ThemeMode themeMode) {
    return () async {
      final data = await showCupertinoModalPopup<ThemeMode>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return HomeMenuThemeModal<ThemeMode>(
            onSelected: (value) => HiveLocalDB.themeMode = value,
            selected: themeMode,
          );
        },
      );
      if (data == null) {
        HiveLocalDB.themeMode = themeMode;
      }
    };
  }

  VoidCallback _openLanguageModal(Locale? locale) {
    return () async {
      final data = await showCupertinoModalPopup<Locale>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return HomeMenuLanguageModal<Locale>(
            onSelected: (value) {
              if (value.languageCode == 'system') {
                HiveLocalDB.locale = null;
              } else {
                HiveLocalDB.locale = value;
              }
            },
            selected: locale,
          );
        },
      );
      if (data == null) {
        HiveLocalDB.locale = locale;
      }
    };
  }

  void _openSupportScreen() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HomeMenuSupportModal(
          children: [
            HomeMenuSupportEmailWidget(
              email: "support@moja.com",
              onTap: () {
                launchUrl(Uri.parse('uri'));
              },
            ),
            HomeMenuSupportWhatsappWidget(
              phone: "+225 0749414602",
              onTap: () {
                launchUrl(Uri.parse('uri'));
              },
            ),
          ],
        );
      },
    );
  }

  void _openShareScreen() {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'hello',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _openLogoutModal() async {
    final data = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return const HomeMenuLogoutModal();
      },
    );
    if (data != null) {
      _signOutUser();
    }
  }

  /// UserService
  late final AsyncController<AsyncState> _userController;

  void _listenUserState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      context.goNamed(HomeScreen.name);
    } else if (state case FailureState<SignOutUserEvent>(:final code)) {
      showSnackBar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _signOutUser() {
    return _userController.run(const SignOutUserEvent());
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentUser = currentUser.value!;
    _currentLocale = HiveLocalDB.locale;
    _localeStream = HiveLocalDB.localeStream;

    _currentThemeMode = HiveLocalDB.themeMode;
    _themeModeStream = HiveLocalDB.themeModeStream;

    _currentNotifications = HiveLocalDB.notifications;
    _notificationsStream = HiveLocalDB.notificationsStream;

    /// UserService
    _userController = AsyncController(SuccessState(_currentUser));
  }

  @override
  Widget build(BuildContext context) {
    const divider = SliverToBoxAdapter(
      child: Divider(thickness: 4.0, height: 4.0),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const HomeMenuAppBar(),
          SliverPadding(padding: kMaterialListPadding / 2),
          SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: HomeMenuProfile(
                  onTap: _openProfileScreen,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuEditPhone(
                  onTap: _openAuthScreen,
                ),
              ),
              divider,
              SliverToBoxAdapter(
                child: StreamBuilder(
                  stream: _notificationsStream,
                  initialData: _currentNotifications,
                  builder: (context, snapshot) {
                    return HomeMenuNotifs(
                      value: snapshot.data ?? false,
                      onChanged: _onNotifsTaped,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder(
                  stream: _themeModeStream,
                  initialData: _currentThemeMode,
                  builder: (context, snapshot) {
                    return HomeMenuTheme(
                      onTap: _openThemeModal(snapshot.data!),
                      value: snapshot.data!.format(context).capitalize(),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder(
                  stream: _localeStream,
                  initialData: _currentLocale,
                  builder: (context, snapshot) {
                    return HomeLanguageTheme(
                      onTap: _openLanguageModal(snapshot.data),
                      value: snapshot.data?.format(context).capitalize(),
                    );
                  },
                ),
              ),
              divider,
              SliverToBoxAdapter(
                child: HomeMenuSupport(
                  onTap: _openSupportScreen,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuShare(
                  onTap: _openShareScreen,
                ),
              ),
              divider,
              SliverToBoxAdapter(
                child: ControllerConsumer(
                  listener: _listenUserState,
                  controller: _userController,
                  builder: (context, state, child) {
                    VoidCallback? onTap = _openLogoutModal;
                    if (state is PendingState) onTap = null;
                    return HomeMenuLogout(
                      onTap: onTap,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
