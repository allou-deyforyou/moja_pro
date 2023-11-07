import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeAccountScreen extends StatefulWidget {
  const HomeAccountScreen({
    super.key,
    required this.relay,
    required this.account,
  });
  final Relay relay;
  final Account account;
  static const name = 'home-transaction';
  static const path = 'transaction';
  static const relayKey = 'relay';
  static const accountKey = 'account';
  @override
  State<HomeAccountScreen> createState() => _HomeAccountScreenState();
}

class _HomeAccountScreenState extends State<HomeAccountScreen> {
  /// Assets
  late TextEditingController _balanceTextController;
  late List<(double, bool)> _balanceSuggestions;
  late Account _currentAccount;
  late Relay _currentRelay;

  double get _balance {
    return double.parse(_balanceTextController.text.trimSpace());
  }

  void _setupData() {
    _currentRelay = widget.relay;
    _currentAccount = widget.account;
    _balanceSuggestions = _currentAccount.balanceSuggestions.map((e) => (e, false)).toList();
    _balanceTextController = TextEditingController(text: _currentAccount.balance?.formatted);
  }

  /// AccountService
  late final AsyncController<AsyncState> _accountController;

  void _listenAccountState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Account>(:final data)) {
      context.pop(data);
    } else if (state case FailureState(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _setAccount() {
    return _accountController.run(SetAccount(
      relayId: _currentRelay.id,
      account: _currentAccount,
      balance: _balance,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _setupData();

    /// AccountService
    _accountController = AsyncController<AsyncState>(const InitState());
  }

  @override
  void didUpdateWidget(covariant HomeAccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account != widget.account || oldWidget.relay != widget.relay) {
      _setupData();
      _accountController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountAppBar(
            leading: const CircleAvatar(),
            title: Text("Solde ${_currentAccount.name}"),
          ),
          SliverToBoxAdapter(
            child: HomeAccountBalanceTextField(
              controller: _balanceTextController,
            ),
          ),
          SliverToBoxAdapter(
            child: StatefulBuilder(
              builder: (context, setState) {
                return HomeAccountSuggestionListView(
                  itemCount: _balanceSuggestions.length,
                  itemBuilder: (context, index) {
                    final (amount, selected) = _balanceSuggestions[index];
                    return HomeAccountSuggestionItemWidget(
                      onSelected: (selected) => setState(
                        () => _balanceSuggestions[index] = (amount, selected),
                      ),
                      selected: selected,
                      amount: amount,
                    );
                  },
                );
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ControllerConsumer(
              listener: _listenAccountState,
              controller: _accountController,
              builder: (context, state, child) {
                VoidCallback? onPressed = _setAccount;
                if (state is PendingState) onPressed = null;
                return HomeAccountSubmittedButton(
                  onPressed: onPressed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
