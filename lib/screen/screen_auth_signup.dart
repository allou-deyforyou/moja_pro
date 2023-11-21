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

  Future<void> _onSubmitPressed() {
    if (_userId != null) {
      return _getUser();
    }
    return _signupUser();
  }

  /// UserService
  late AsyncController<AsyncState> _userController;
  String? _userId;

  void _listenUserState(BuildContext context, AsyncState state) {
    if (state case SuccessState<String>(:final data)) {
      _userId = data;
      _getUser();
    } else if (state case SuccessState<User>(:final data)) {
      currentUser.value = data;
      context.goNamed(HomeScreen.name);
    } else if (state case FailureState<SignupUserEvent>(:final code)) {
      showErrorSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _getUser() {
    return _userController.run(GetUserEvent(
      id: _userId!,
    ));
  }

  Future<void> _signupUser() {
    return _userController.run(SignupUserEvent(
      countryId: _country.id!,
      relayName: _fullname,
      userPhone: _phone,
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
          const SliverPadding(padding: kMaterialListPadding),
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
                VoidCallback? onPressed = _onSubmitPressed;
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
