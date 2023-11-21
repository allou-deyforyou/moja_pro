import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  Stream<bool>? _notificationsStream;
  bool? _currentNotifications;

  Stream<ThemeMode>? _themeModeStream;
  ThemeMode? _currentThemeMode;

  Stream<Locale>? _localeStream;
  Locale? _currentLocale;

  void _openProfileScreen() {
    context.pushNamed(ProfileScreen.name);
  }

  void _openAuthScreen() {
    context.pushNamed(AuthScreen.name, extra: {
      AuthScreen.currentUserKey: _currentUser,
    });
  }

  void _onNotifsTaped(bool active) {
    DatabaseConfig.notifications = active;
  }

  VoidCallback _openThemeModal(ThemeMode themeMode) {
    return () async {
      final data = await showDialog<ThemeMode>(
        context: context,
        builder: (context) {
          return HomeMenuThemeModal<ThemeMode>(
            onSelected: (value) => DatabaseConfig.themeMode = value,
            selected: themeMode,
          );
        },
      );
      if (data == null) {
        DatabaseConfig.themeMode = themeMode;
      }
    };
  }

  VoidCallback _openLanguageModal(Locale? locale) {
    return () async {
      final data = await showDialog<Locale>(
        context: context,
        builder: (context) {
          return HomeMenuLanguageModal<Locale>(
            onSelected: (value) {
              if (value.languageCode == 'system') {
                DatabaseConfig.locale = null;
              } else {
                DatabaseConfig.locale = value;
              }
            },
            selected: locale,
          );
        },
      );
      if (data == null) {
        DatabaseConfig.locale = locale;
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
              onTap: () {
                launchUrl(Uri.parse('uri'));
              },
            ),
            HomeMenuSupportWhatsappWidget(
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
    final data = await showDialog<bool>(
      context: context,
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
      switch (code) {}
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
    _currentLocale = DatabaseConfig.locale;
    _localeStream = DatabaseConfig.localeStream;

    _currentThemeMode = DatabaseConfig.themeMode;
    _themeModeStream = DatabaseConfig.themeModeStream;

    _currentNotifications = DatabaseConfig.notifications;
    _notificationsStream = DatabaseConfig.notificationsStream;

    /// UserService
    _userController = AsyncController(SuccessState(_currentUser));
  }

  @override
  Widget build(BuildContext context) {
    const divider = SliverToBoxAdapter(child: Divider());

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          const HomeMenuAppBar(),
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
                  initialData: _currentNotifications,
                  stream: _notificationsStream,
                  builder: (context, snapshot) {
                    return HomeMenuNotifs(
                      onChanged: _onNotifsTaped,
                      value: snapshot.data!,
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
