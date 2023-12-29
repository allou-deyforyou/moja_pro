import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:permission_handler/permission_handler.dart';

import '_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});
  static const name = 'onboarding';
  static const path = '/onboarding';
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  ///Assets
  AppLifecycleListener? _appLifecycleListener;

  void _onResume() {
    _requestPermission();
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
  }

  void _openPermissionModal() async {
    final data = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const OnBoardingPermissionModal();
      },
    );
    if (data != null) {
      await openAppSettings();
      _appLifecycleListener = AppLifecycleListener(onResume: _onResume);
    }
  }

  /// PermissionService
  late AsyncController<AsyncState> _permissionController;

  void _listenPermissionState(BuildContext context, AsyncState state) {
    if (state is SuccessState<Permission>) {
      context.goNamed(HomeScreen.name);
    } else if (state case FailureState<String>(:final data)) {
      switch (data) {
        case 'no-permission':
          _openPermissionModal();
          break;
        default:
      }
    }
  }

  Future<void> _requestPermission() {
    return _permissionController.run(const RequestPermissionEvent(
      permission: Permission.locationWhenInUse,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// PermissionService
    _permissionController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _appLifecycleListener?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      listener: _listenPermissionState,
      controller: _permissionController,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: OnBoardingSubmittedButton(
                onPressed: _requestPermission,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
