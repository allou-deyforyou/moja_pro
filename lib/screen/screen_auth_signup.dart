import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthSignupScreen extends StatefulWidget {
  const AuthSignupScreen({
    super.key,
    required this.uid,
    required this.phone,
    required this.country,
  });

  final String uid;
  final String phone;
  final Country country;

  static const uidKey = 'uid';
  static const phoneKey = 'phone';
  static const countryKey = 'country';

  static const name = 'auth-signup';
  static const path = 'signup';
  @override
  State<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends State<AuthSignupScreen> {
  /// Assets
  late String _uid;
  late String _phone;
  late Country _country;
  late TextEditingController _fullnameTextController;

  String get _fullname {
    return _fullnameTextController.text.trim();
  }

  void _showErrorSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      content: Text(text),
    ));
  }

  /// UserService
  late AsyncController<AsyncState> _userController;

  void _listenUserState(BuildContext context, AsyncState state) {
    if (state is SuccessState<User>) {
      currentUserController.value = state.data;
      context.goNamed(HomeScreen.name);
    } else if (state case FailureState<SignupUserEvent>(:final code)) {
      _showErrorSnackbar(switch (code) {
        _ => "Une erreur s'est produite",
      });
    }
  }

  Future<void> _signupUser() {
    return _userController.run(SignupUserEvent(
      country: _country,
      relay: _fullname,
      phone: _phone,
      uid: _uid,
    ));
  }

  void _setupData() {
    _uid = widget.uid;
    _phone = widget.phone;
    _country = widget.country;
    _fullnameTextController = TextEditingController();

    /// UserService
    _userController = AsyncController<AsyncState>(const InitState());
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _setupData();
  }

  @override
  void didUpdateWidget(covariant AuthSignupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country != widget.country || oldWidget.uid != widget.uid || oldWidget.phone != widget.phone) {
      _setupData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const AuthSignupAppBar(),
          SliverToBoxAdapter(
            child: AuthSignupFullnameTextField(
              controller: _fullnameTextController,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: kMinInteractiveDimension)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ControllerConsumer(
              listener: _listenUserState,
              controller: _userController,
              builder: (context, state, child) {
                VoidCallback? onPressed = _signupUser;
                if (state is PendingState) onPressed = null;
                return AuthSignupContinueButton(
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
