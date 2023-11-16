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
    if (currentUser.value != null) return null;
    return AuthScreen.path;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
  late User _currentUser;
  late Relay _currentRelay;
  late List<Account> _relayAccounts;

  void _openMenu() {
    context.pushNamed(HomeMenuScreen.name);
  }

  void _onAvailableChanged(bool value) {
    _setRelay(availability: value);
  }

  Future<Account?> _onAccountTap(Account account) {
    return context.pushNamed<Account>(HomeAccountScreen.name, extra: {
      HomeAccountScreen.relayKey: _currentRelay,
      HomeAccountScreen.accountKey: account,
    });
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  bool _canRebuildRelay(AsyncState previousState, AsyncState currentState) {
    if (previousState is SuccessState<Relay> && currentState is PendingState) {
      return false;
    }
    return true;
  }

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      // _getRelay();
    } else if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      _relayAccounts = _currentRelay.accounts!;
    } else if (state case FailureState<GetRelay>(:final code)) {
      switch (code) {}
    } else if (state case FailureState<SetRelay>(:final code)) {
      switch (code) {}
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
    _currentUser = currentUser.value!;
    _currentRelay = _currentUser.relay;
    _relayAccounts = _currentRelay.accounts ?? const [];

    /// UserService
    _relayController = AsyncController(SuccessState(_currentRelay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _getRelay,
        child: CustomScrollView(
          slivers: [
            ControllerConsumer(
              autoListen: true,
              listener: _listenRelayState,
              controller: _relayController,
              builder: (context, state, child) {
                bool active = _currentRelay.isActive;
                return StatefulBuilder(
                  builder: (context, setState) {
                    void onChanged(bool value) {
                      setState(() => active = value);
                      _onAvailableChanged(value);
                    }

                    return SliverAppBar.medium(
                      pinned: true,
                      leading: HomeBarsButton(
                        onPressed: _openMenu,
                      ),
                      title: HomeListTile(
                        title: Text(_currentRelay.name.toUpperCase()),
                        subtitle: const Text("EN LIGNE"),
                      ),
                      actions: [
                        HomeAvailableSwitch(
                          onChanged: onChanged,
                          value: active,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ControllerBuilder(
              canRebuild: _canRebuildRelay,
              controller: _relayController,
              builder: (context, state, child) {
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
                          key: ValueKey(item),
                          name: item.name,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
