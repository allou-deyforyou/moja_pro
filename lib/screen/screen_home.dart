import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const name = 'home';
  static const path = '/';

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (currentUser.value != null) {
      return null;
    }
    return AuthScreen.path;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
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
    if (currentState is FailureState) return true;
    return previousState is SuccessState<Relay> && currentState is SuccessState<Relay>;
  }

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _getRelay();
    } else if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      _relayAccounts = _currentRelay.accounts!;
    } else if (state case FailureState<GetRelayEvent>(:final code)) {
      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    } else if (state case FailureState<SetRelayEvent>(:final code)) {
      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _getRelay() {
    return _relayController.run(GetRelayEvent(
      id: _currentRelay.id,
    ));
  }

  Future<void> _setRelay({required bool availability}) {
    return _relayController.run(SetRelayEvent(
      availability: availability,
      relay: _currentRelay,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    final user = currentUser.value!;
    _currentRelay = user.relays!.first;
    _relayAccounts = _currentRelay.accounts!;

    /// RelayService
    _relayController = AsyncController(SuccessState(_currentRelay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _getRelay,
        child: CustomScrollView(
          slivers: [
            HomeSliverAppBar(
              leading: HomeBarsButton(
                onPressed: _openMenu,
              ),
              trailing: ControllerConsumer(
                autoListen: true,
                listener: _listenRelayState,
                controller: _relayController,
                canRebuild: _canRebuildRelay,
                builder: (context, state, child) {
                  bool active = _currentRelay.availability != null;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      void onChanged(bool value) {
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
