import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.currentUser});
  final User? currentUser;
  static const currentUserKey = 'current_user';
  static const name = 'auth';
  static const path = '/auth';
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// Assets
  User? _currentUser;
  late TextEditingController _phoneTextController;

  String get _phone {
    return _phoneTextController.text.trim();
  }

  void _openAuthCountryModal() async {
    final data = await showModalBottomSheet<Country>(
      context: context,
      builder: (context) {
        return AuthCountryModal<Country>(
          initialValue: _currentCountry,
          values: _countryList!,
        );
      },
    );
    if (data != null) {
      _currentCountry = data;
    }
  }

  /// CountryService
  late AsyncController<AsyncState> _countryController;
  List<Country>? _countryList;
  Country? _currentCountry;

  void _listenCountryState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _searchCountry();
    } else if (state is SuccessState<List<Country>>) {
      _countryList = state.data;
      _currentCountry = _countryList!.firstOrNull;
    } else if (state is FailureState) {
      switch (state.code) {}
    }
  }

  void _searchCountry() {
    _countryController.run(const SearchCountry());
  }

  /// AuthService
  late AsyncController<AsyncState> _authController;
  late Duration _timeout;

  void _listenAuthState(BuildContext context, AsyncState state) {
    if (state is AuthStateSmsCodeSent) {
      _timeout = state.timeout;
      context.pushNamed(AuthSigninScreen.name);
    } else if (state is FailureState) {
      switch (state.code) {}
    }
  }

  Future<void> _onSubmitted() async {
    _authController.run(VerifyPhoneNumberEvent(
      timeout: _timeout + const Duration(seconds: 30),
      country: _currentCountry!,
      phoneNumber: _phone,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentUser = widget.currentUser;
    _phoneTextController = TextEditingController();

    /// CountryService
    _countryController = currentCountryController;

    /// AuthService
    _authController = currentAuthController;
    _timeout = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverVisibility(
            visible: _currentUser != null,
            sliver: const AuthEditPhoneAppBar(),
            replacementSliver: const AuthAppBar(),
          ),
          SliverToBoxAdapter(
            child: AuthPhoneTextField(
              controller: _phoneTextController,
              prefixIcon: ControllerConsumer(
                autoListen: true,
                listener: _listenCountryState,
                controller: _countryController,
                builder: (context, state, child) {
                  final onPressed = switch (state) {
                    SuccessState<List<Country>>() => _openAuthCountryModal,
                    FailureState() => _searchCountry,
                    _ => null,
                  };
                  return AuthDialCodeButton(
                    dialCode: _currentCountry?.dialCode,
                    countryCode: _currentCountry?.code,
                    onPressed: onPressed,
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: kMinInteractiveDimension)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ControllerConsumer(
              listener: _listenAuthState,
              controller: _authController,
              builder: (context, state, child) {
                VoidCallback? onPressed = _onSubmitted;
                if (state is PendingState) onPressed = null;
                return AuthSubmittedButton(
                  onPressed: onPressed,
                  timeout: _timeout,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
