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
  late Account _currentAccount;
  late Relay _currentRelay;

  double get _balance {
    return double.tryParse(_balanceTextController.text.replaceAll('.', '').trimSpace()) ?? 0;
  }

  void _setupData() {
    _currentRelay = widget.relay;
    _currentAccount = widget.account;
    final balance = _currentAccount.balance?.formatted;
    _balanceTextController = TextEditingController(text: balance);
    _balanceTextController.selection = TextSelection(
      extentOffset: balance?.length ?? 0,
      baseOffset: 0,
    );
  }

  /// AccountService
  late final AsyncController<AsyncState> _accountController;

  void _listenAccountState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Account>(:final data)) {
      context.pop(data);
    } else if (state case FailureState<String>(:final data)) {
      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _setAccount() {
    return _accountController.run(SetAccountEvent(
      account: _currentAccount,
      relay: _currentRelay,
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
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountSliverAppBar(
            name: _currentAccount.name,
            cash: _currentAccount.cash,
            image: _currentAccount.image,
          ),
          SliverToBoxAdapter(
            child: HomeAccountBalanceTextField(
              controller: _balanceTextController,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ControllerBuilder(
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
