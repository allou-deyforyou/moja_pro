import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const name = 'home';
  static const path = '/';

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (currentUserController.value != null) return null;
    return AuthScreen.path;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
  late User _currentUser;
  late Relay _currentRelay;
  late List<Account> _accountList;
  late final ValueNotifier<bool> _availableController;

  void _onReorder(int oldIndex, int newIndex) {
    final oldItem = _accountList.removeAt(oldIndex);
    _accountList.insert(newIndex, oldItem);
  }

  void _openMenu() {
    context.pushNamed(HomeMenuScreen.name);
  }

  void _availableChanged(bool value) {
    _availableController.value = value;
    _setRelay(availability: value);
  }

  VoidCallback _onAccountTap(List<Account> accounts, int index) {
    return () async {
      final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
        HomeAccountScreen.accountKey: accounts[index],
        HomeAccountScreen.relayKey: _currentRelay,
      });
      if (data != null) accounts[index] = data;
    };
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _getRelay();
    } else if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
    } else if (state is FailureState<SetRelay>) {
      switch (state.code) {}
    }
  }

  Future<void> _getRelay() {
    return _relayController.run(GetRelay(
      id: _currentRelay.id,
    ));
  }

  Future<void> _setRelay({required bool availability}) {
    return _relayController.run(SetRelay(
      availability: availability,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentUser = currentUserController.value!;
    _currentRelay = _currentUser.relays!.first;
    _accountList = _currentRelay.accounts!;
    _availableController = ValueNotifier(false);

    /// UserService
    _relayController = AsyncController(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64.0,
        foregroundColor: Colors.white,
        titleTextStyle: context.theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
        title: const Text(
          "Definissez la localité de votre point relais pour permettre aux clients de le retrouver facilement.",
          softWrap: true,
          maxLines: 2,
        ),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(ProfileLocationScreen.name),
            icon: const Icon(CupertinoIcons.arrow_right),
          )
        ],
        backgroundColor: CupertinoColors.systemRed.resolveFrom(context),
      ),
      body: CustomScrollView(
        slivers: [
          HomeSliverAppBar(
            leading: HomeBarsFilledButton(
              onPressed: _openMenu,
            ),
            trailing: ControllerListener(
              autoListen: true,
              listener: _listenRelayState,
              controller: _relayController,
              child: ValueListenableBuilder(
                valueListenable: _availableController,
                builder: (context, value, child) {
                  return HomeAvailableSwitch(
                    onChanged: _availableChanged,
                    value: value,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: kTabLabelPadding,
            sliver: StatefulBuilder(
              builder: (context, setState) {
                void onReorder(int oldIndex, int newIndex) => setState(() => _onReorder(oldIndex, newIndex));
                return HomeAccountSliverGridView(
                  onReorder: onReorder,
                  itemCount: _accountList.length,
                  itemBuilder: (context, index) {
                    final item = _accountList[index];
                    return HomeAccountCard(
                      onPressed: _onAccountTap(_accountList, index),
                      amount: item.balance,
                      key: ValueKey(item),
                      name: item.name,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
