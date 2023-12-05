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
  static const name = 'home-account';
  static const path = 'account';
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
    final balance = _currentAccount.balance;
    _balanceTextController = TextEditingController(text: balance?.formatted);
    _balanceTextController.selection = TextSelection(
      extentOffset: balance?.formatted.length ?? 0,
      baseOffset: 0,
    );
  }

  /// AccountService
  late final AsyncController<AsyncState> _accountController;

  void _listenAccountState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Account>(:final data)) {
      context.pop(data);
    } else if (state case FailureState<SetAccountEvent>(:final code)) {
     showSnackbar(
        context: context,
        text: switch (code) {
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
          ),
          SliverToBoxAdapter(
            child: HomeAccountBalanceTextField(
              controller: _balanceTextController,
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
