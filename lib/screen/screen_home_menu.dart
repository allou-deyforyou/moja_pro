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
    _currentUser = currentUserController.value!;
  }

  @override
  Widget build(BuildContext context) {
    const largeSpace = SliverToBoxAdapter(child: Divider(height: 26.0));

    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          const HomeMenuAppBar(),
          SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: HomeMenuProfileListTile(
                  onTap: _openProfileScreen,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuEditPhoneListTile(
                  onTap: _openAuthScreen,
                ),
              ),
              largeSpace,
              SliverToBoxAdapter(
                child: HomeMenuNotifsListTile(
                  onChanged: _onNotifsTaped,
                  value: true,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuThemeListTile(
                  onTap: _openThemeModal,
                  trailing: const Text("Systeme"),
                ),
              ),
              largeSpace,
              SliverToBoxAdapter(
                child: HomeMenuSupportListTile(
                  onTap: _openSupportScreen,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeMenuShareListTile(
                  onTap: _openShareScreen,
                ),
              ),
              largeSpace,
              SliverToBoxAdapter(
                child: HomeMenuLogoutListTile(
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
