import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:service_tools/service_tools.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screen/_screen.dart';

void main() {
  runService(const MyService()).whenComplete(() => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Assets
  late final GoRouter _router;

  Stream<ThemeMode>? _themeModeStream;
  ThemeMode? _currentThemeMode;

  Stream<Locale?>? _localeStream;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentLocale = HiveLocalDB.locale;
    _localeStream = HiveLocalDB.localeStream;

    _currentThemeMode = HiveLocalDB.themeMode;
    _themeModeStream = HiveLocalDB.themeModeStream;

    _router = GoRouter(
      refreshListenable: currentUser,
      observers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseConfig.firebaseAnalytics,
        ),
      ],
      routes: [
        GoRoute(
          name: HomeScreen.name,
          path: HomeScreen.path,
          redirect: HomeScreen.redirect,
          pageBuilder: (context, state) {
            return CupertinoPage(
              name: state.name,
              key: state.pageKey,
              child: const HomeScreen(),
            );
          },
          routes: [
            GoRoute(
              name: ProfileScreen.name,
              path: ProfileScreen.path,
              pageBuilder: (context, state) {
                return CupertinoPage(
                  name: state.name,
                  key: state.pageKey,
                  child: const ProfileScreen(),
                );
              },
              routes: [
                GoRoute(
                  name: ProfilePhotoScreen.name,
                  path: ProfilePhotoScreen.path,
                  pageBuilder: (context, state) {
                    final data = state.extra as Map<String, dynamic>;
                    return CupertinoPage(
                      name: state.name,
                      key: state.pageKey,
                      child: ProfilePhotoScreen(
                        relay: data[ProfilePhotoScreen.relayKey],
                      ),
                    );
                  },
                ),
                GoRoute(
                  name: ProfileLocationScreen.name,
                  path: ProfileLocationScreen.path,
                  pageBuilder: (context, state) {
                    final data = state.extra as Map<String, dynamic>;
                    return CupertinoPage(
                      name: state.name,
                      key: state.pageKey,
                      child: ProfileLocationScreen(
                        relay: data[ProfileLocationScreen.relayKey],
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: HomeMenuScreen.name,
              path: HomeMenuScreen.path,
              pageBuilder: (context, state) {
                return CupertinoPage(
                  name: state.name,
                  key: state.pageKey,
                  fullscreenDialog: true,
                  child: const HomeMenuScreen(),
                );
              },
            ),
            GoRoute(
              name: HomeAccountScreen.name,
              path: HomeAccountScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return DialogPage(
                  name: state.name,
                  key: state.pageKey,
                  child: HomeAccountScreen(
                    account: data[HomeAccountScreen.accountKey],
                    relay: data[HomeAccountScreen.relayKey],
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AuthScreen.path,
          name: AuthScreen.name,
          redirect: AuthScreen.redirect,
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            return CupertinoPage(
              name: state.name,
              key: state.pageKey,
              child: AuthScreen(
                currentUser: data?[AuthScreen.currentUserKey],
              ),
            );
          },
          routes: [
            GoRoute(
              path: AuthSigninScreen.path,
              name: AuthSigninScreen.name,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>?;
                return CupertinoPage(
                  name: state.name,
                  key: state.pageKey,
                  child: AuthSigninScreen(
                    currentUser: data?[AuthScreen.currentUserKey],
                  ),
                );
              },
            ),
            GoRoute(
              path: AuthSignupScreen.path,
              name: AuthSignupScreen.name,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return CupertinoPage(
                  name: state.name,
                  key: state.pageKey,
                  child: AuthSignupScreen(
                    country: data[AuthSignupScreen.countryKey],
                    phone: data[AuthSignupScreen.phoneKey],
                    uid: data[AuthSignupScreen.uidKey],
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: OnBoardingScreen.name,
          path: OnBoardingScreen.path,
          pageBuilder: (context, state) {
            return CupertinoPage(
              name: state.name,
              key: state.pageKey,
              child: const OnBoardingScreen(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(context.theme.colorScheme.tertiaryContainer);

    return StreamBuilder(
      stream: _localeStream,
      initialData: _currentLocale,
      builder: (context, localeSnapshot) {
        return StreamBuilder<ThemeMode>(
          stream: _themeModeStream,
          initialData: _currentThemeMode,
          builder: (context, themeModeSnapshot) {
            return MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeSnapshot.data?.normalize(),
              themeMode: themeModeSnapshot.data,
              color: AppThemes.primaryColor,
              darkTheme: AppThemes.darkTheme,
              theme: AppThemes.theme,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
