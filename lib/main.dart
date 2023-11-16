import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:service_tools/service_tools.dart';

import 'screen/_screen.dart';

void main() {
  runService(const MyService()).whenComplete(() => runApp(const MyApp()));
}

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Assets
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    /// Assets
    _router = GoRouter(
      refreshListenable: currentUser,
      routes: [
        GoRoute(
          name: HomeScreen.name,
          path: HomeScreen.path,
          redirect: HomeScreen.redirect,
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: HomeScreen(),
            );
          },
          routes: [
            GoRoute(
              name: ProfileScreen.name,
              path: ProfileScreen.path,
              pageBuilder: (context, state) {
                return const CupertinoPage(
                  child: ProfileScreen(),
                );
              },
              routes: [
                GoRoute(
                  name: ProfileLocationScreen.name,
                  path: ProfileLocationScreen.path,
                  pageBuilder: (context, state) {
                    return const CupertinoPage(
                      child: ProfileLocationScreen(),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: HomeMenuScreen.name,
              path: HomeMenuScreen.path,
              pageBuilder: (context, state) {
                return const DialogPage(
                  child: HomeMenuScreen(),
                );
              },
            ),
            GoRoute(
              name: HomeAccountScreen.name,
              path: HomeAccountScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return DialogPage(
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
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            return CupertinoPage(
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
                return const CupertinoPage(
                  child: AuthSigninScreen(),
                );
              },
            ),
            GoRoute(
              path: AuthSignupScreen.path,
              name: AuthSignupScreen.name,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return CupertinoPage(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      theme: AppThemes.theme,
      routerConfig: _router,
    );
  }
}
