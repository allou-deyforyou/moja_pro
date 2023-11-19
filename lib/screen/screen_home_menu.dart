import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            selected: themeMode,
          );
        },
      );
      if (data != null) {
        DatabaseConfig.themeMode = data;
      }
    };
  }

  VoidCallback _openLanguageModal(Locale? locale) {
    return () async {
      final data = await showDialog<Locale>(
        context: context,
        builder: (context) {
          return HomeMenuLanguageModal<Locale>(
            selected: locale,
          );
        },
      );
      if (data != null) {
        if (data.languageCode == 'system') {
          DatabaseConfig.locale = null;
        } else {
          DatabaseConfig.locale = data;
        }
      }
    };
  }

  void _openSupportScreen() {}

  void _openShareScreen() {}

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentUser = currentUser.value!;
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
                  initialData: DatabaseConfig.notifications,
                  stream: DatabaseConfig.notificationsStream,
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
                  stream: DatabaseConfig.themeModeStream,
                  initialData: DatabaseConfig.themeMode,
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
                  initialData: DatabaseConfig.locale,
                  stream: DatabaseConfig.localeStream,
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
                child: HomeMenuLogout(
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
