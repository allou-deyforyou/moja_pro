import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({
    super.key,
    required this.relay,
  });
  final Relay relay;
  static const relayKey = 'relay';
  static const name = 'profile-photo';
  static const path = 'photo';
  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  /// Assets
  late Relay _currentRelay;

  void _onEditPressed() async {
    final data = await openImageEditorModal(context: context);
    if (data != null) {
      _setRelay(rawImage: data);
    }
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
    } else if (state case FailureState<String>(:final data)) {
      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _setRelay({
    Uint8List? rawImage,
  }) {
    return _relayController.run(SetRelayEvent(
      relay: _currentRelay,
      rawImage: rawImage,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.relay;

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ProfilePhotoAppBar(
        actions: [
          ProfilePhotoEditButton(
            onPressed: _onEditPressed,
          ),
        ],
      ),
      body: ControllerBuilder(
        listener: _listenRelayState,
        controller: _relayController,
        builder: (context, state, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ProfilePhotoWidget(
                imageUrl: _currentRelay.image!,
              ),
              if (state is PendingState) const ProfileAvatarProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}
