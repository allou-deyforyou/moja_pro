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

  void _onNotifsTaped(bool active) {}

  void _openThemeModal() {}

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
                child: HomeMenuNotifs(
                  onChanged: _onNotifsTaped,
                  value: true,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuTheme(
                  onTap: _openThemeModal,
                  trailing: const Text("Systeme"),
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
