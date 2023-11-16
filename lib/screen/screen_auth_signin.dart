import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthSigninScreen extends StatefulWidget {
  const AuthSigninScreen({super.key});
  static const name = 'auth-signin';
  static const path = 'signin';
  @override
  State<AuthSigninScreen> createState() => _AuthSigninScreenState();
}

class _AuthSigninScreenState extends State<AuthSigninScreen> {
  /// Assets
  late TextEditingController _codeTextController;

  Future<void> _onSubmitPressed() {
    if (_userId != null) {
      return _getUser();
    } else if (_uid != null) {
      return _signinUser();
    }
    return _signin();
  }

  /// AuthService
  late final AsyncController<AsyncState> _authController;
  late Country _currentCountry;
  late String _verificationId;
  late String _phoneNumber;
  late int? _resendToken;
  late Duration _timeout;
  String? _idToken;
  String? _uid;

  void _listenAuthState(BuildContext context, AsyncState state) async {
    if (state is AuthStateSmsCodeSent) {
      _timeout = state.timeout;
      _currentCountry = state.country;
      _resendToken = state.resendToken;
      _phoneNumber = state.phoneNumber;
      _verificationId = state.verificationId;
    } else if (state is AuthStatePhoneNumberVerified) {
      _codeTextController.text = state.credential.smsCode!;
    } else if (state is AuthStateUserSigned) {
      _uid = state.userId;
      _idToken = state.idToken;
      _signinUser();
    } else if (state is FailureState) {
      switch (state.code) {}
    }
  }

  Future<void> _signin() {
    return _authController.run(SignInEvent(
      smsCode: _codeTextController.text,
      verificationId: _verificationId,
    ));
  }

  Future<void> _verifyPhoneNumber() {
    return _authController.run(VerifyPhoneNumberEvent(
      timeout: _timeout + const Duration(seconds: 30),
      phoneNumber: _phoneNumber,
      resendToken: _resendToken,
      country: _currentCountry,
    ));
  }

  /// UserService
  late final AsyncController<AsyncState> _userController;
  String? _userId;

  void _listenUserState(BuildContext context, AsyncState state) {
    if (state case SuccessState<String>(:final data)) {
      _userId = data;
      _getUser();
    } else if (state case SuccessState<User>(:final data)) {
      currentUser.value = data;
      context.goNamed(HomeScreen.name);
    } else if (state case FailureState<SigninUserEvent>(:final code)) {
      switch (code) {
        case 'no-record':
          context.pushNamed(AuthSignupScreen.name, extra: {
            AuthSignupScreen.countryKey: _currentCountry,
            AuthSignupScreen.phoneKey: _phoneNumber,
            AuthSignupScreen.uidKey: _uid,
          });
          break;
        default:
      }
    }
  }

  Future<void> _getUser() {
    return _userController.run(GetUserEvent(
      id: _userId!,
    ));
  }

  Future<void> _signinUser() {
    return _userController.run(SigninUserEvent(
      idToken: _idToken!,
      uid: _uid!,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _codeTextController = TextEditingController();

    /// AuthService
    _authController = currentAuth;

    /// UserService
    _userController = AsyncController(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      autoListen: true,
      listener: _listenAuthState,
      controller: _authController,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const AuthSigninAppBar(),
            SliverToBoxAdapter(
              child: AuthSignupCodePinTextField(
                controller: _codeTextController,
              ),
            ),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  return AuthSigninResendButton(
                    timeout: _timeout,
                    onPressed: _verifyPhoneNumber,
                  );
                },
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: ValueListenableBuilder(
                valueListenable: _authController,
                builder: (context, authState, child) {
                  return ControllerConsumer(
                    autoListen: true,
                    listener: _listenUserState,
                    controller: _userController,
                    builder: (context, userState, child) {
                      VoidCallback? onPressed = _onSubmitPressed;
                      if (authState is PendingState || userState is PendingState) onPressed = null;
                      return AuthSigninSubmittedButton(
                        onPressed: onPressed,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
