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

  Future<bool?> _openAuthConfirmModal({required String phone}) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AuthConfirmPhoneModal(
          phone: phone,
        );
      },
    );
  }

  void _openAuthCountryModal() async {
    final data = await showModalBottomSheet<Country>(
      context: context,
      builder: (context) {
        final code = Localizations.localeOf(context).languageCode;
        return AuthCountryModal<Country>(
          valueFormatted: (item) {
            final translations = item.translations!;
            final name = translations[code] ?? translations.values.first;
            return '${CustomString.toFlag(item.code!)}  $name';
          },
          initialValue: _currentCountry,
          values: _countryList!,
        );
      },
    );
    if (data != null) {
      _currentCountry = data;
    }
  }

  void _onSubmitted() async {
    final data = await _openAuthConfirmModal(phone: _phone);
    if (data != null) {
      return _verifyPhoneNumber();
    }
  }

  /// CountryService
  late AsyncController<AsyncState> _countryController;
  List<Country>? _countryList;
  Country? _currentCountry;

  void _listenCountryState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _searchCountry();
    } else if (state case SuccessState<List<Country>>(:final data)) {
      _countryList = data;
      _currentCountry = _countryList!.firstOrNull;
    } else if (state case FailureState(:final code)) {
      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  void _searchCountry() {
    _countryController.run(const SelectCountry());
  }

  /// AuthService
  late AsyncController<AsyncState> _authController;
  late Duration _timeout;

  void _listenAuthState(BuildContext context, AsyncState state) {
    if (state is AuthStateSmsCodeSent) {
      _timeout = state.timeout;
      context.pushNamed(AuthSigninScreen.name, extra: {
        AuthSigninScreen.currentUserKey: _currentUser,
      });
    } else if (state case FailureState(:final code)) {
      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _verifyPhoneNumber() async {
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
    _phoneTextController = TextEditingController(text: _currentUser?.phone);
    _phoneTextController.selection = TextSelection(
      extentOffset: _currentUser?.phone.length ?? 0,
      baseOffset: 0,
    );

    /// CountryService
    _countryController = currentCountry;

    /// AuthService
    _authController = currentAuth;
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
          const SliverPadding(padding: kMaterialListPadding),
          SliverToBoxAdapter(
            child: ControllerConsumer(
              autoListen: true,
              listener: _listenCountryState,
              controller: _countryController,
              builder: (context, state, child) {
                final onPressed = switch (state) {
                  SuccessState<List<Country>>() => _openAuthCountryModal,
                  FailureState() => _searchCountry,
                  _ => null,
                };
                return AuthPhoneTextField(
                  autofocus: _currentUser != null,
                  controller: _phoneTextController,
                  format: _currentCountry?.phoneFormat,
                  prefixIcon: AuthDialCodeButton(
                    dialCode: _currentCountry?.dialCode,
                    countryCode: _currentCountry?.code,
                    onPressed: onPressed,
                  ),
                );
              },
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
