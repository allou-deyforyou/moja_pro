import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const name = 'profile';
  static const path = 'profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Assets
  late Relay _currentRelay;

  String? _currentImage;
  Place? _currentLocation;
  late String _currentName;
  late String _currentContact;

  void _openAvatarScreen() {
    context.pushNamed(ProfilePhotoScreen.name, extra: {
      ProfilePhotoScreen.relayKey: _currentRelay,
    });
  }

  void _openEditorModal() async {
    final data = await openImageEditorModal(
      context: context,
    );

    if (data != null) {
      _currentImage = '';
      _setRelay(rawImage: data);
    }
  }

  void _openNameModal() async {
    final data = await showDialog<String>(
      context: context,
      builder: (context) {
        return ProfileEditNameModal(
          name: _currentRelay.name,
        );
      },
    );
    if (data != null) {
      _currentName = data;
      _setRelay(name: data);
    }
  }

  void _onContactPressed() async {
    final data = await showDialog<String>(
      context: context,
      builder: (context) {
        return ProfileEditContactModal(
          contact: _currentRelay.contacts!.first,
        );
      },
    );
    if (data != null) {
      _currentContact = data;
      _setRelay(contacts: [data]);
    }
  }

  void _openLocationScreen() async {
    context.pushNamed<Relay>(ProfileLocationScreen.name, extra: {
      ProfileLocationScreen.relayKey: _currentRelay,
    });
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;
  StreamSubscription? _relaySubscription;

  bool _canAvatarRebuild(AsyncState previousState, AsyncState currentState) {
    if (currentState is PendingState && _currentRelay.image == _currentImage) {
      return false;
    }
    return true;
  }

  bool _canNameRebuild(AsyncState previousState, AsyncState currentState) {
    if (currentState is PendingState && _currentRelay.name == _currentName) {
      return false;
    }
    return true;
  }

  bool _canContactsRebuild(AsyncState previousState, AsyncState currentState) {
    if (currentState is PendingState && listEquals(_currentRelay.contacts, [_currentContact])) {
      return false;
    }
    return true;
  }

  bool _canLocationRebuild(AsyncState previousState, AsyncState currentState) {
    if (currentState is PendingState && _currentRelay.location == _currentLocation) {
      return false;
    }
    return true;
  }

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _loadRelay();
    } else if (state case SuccessState<StreamSubscription>(:final data)) {
      _relaySubscription = data;
    } else if (state case SuccessState<Relay>(:final data)) {
      _currentRelay = data;
      _currentName = _currentRelay.name;
      _currentImage = _currentRelay.image;
      _currentLocation = _currentRelay.location;
      _currentContact = _currentRelay.contacts!.first;
    } else if (state case FailureState<String>(:final data)) {
      _currentName = _currentRelay.name;
      _currentImage = _currentRelay.image;
      _currentLocation = _currentRelay.location;
      _currentContact = _currentRelay.contacts!.first;

      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _loadRelay() {
    return _relayController.run(LoadRelayEvent(
      relayId: _currentRelay.id,
      listen: true,
    ));
  }

  Future<void> _setRelay({
    String? name,
    Uint8List? rawImage,
    List<String>? contacts,
  }) {
    return _relayController.run(SetRelayEvent(
      relay: _currentRelay,
      contacts: contacts,
      rawImage: rawImage,
      name: name,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    final user = currentUser.value!;
    _currentRelay = user.relays.first;

    _currentName = _currentRelay.name;
    _currentImage = _currentRelay.image;
    _currentLocation = _currentRelay.location;
    _currentContact = _currentRelay.contacts!.first;

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// RelayService
    _relaySubscription?.cancel();
    _relayController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      autoListen: true,
      listener: _listenRelayState,
      controller: _relayController,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const ProfileAppBar(),
            const SliverPadding(padding: kMaterialListPadding),
            SliverToBoxAdapter(
              child: ControllerBuilder(
                controller: _relayController,
                canRebuild: _canAvatarRebuild,
                builder: (context, state, child) {
                  return ProfileAvatarWrapper(
                    onEditPressed: _openEditorModal,
                    content: switch (state) {
                      PendingState() => const ProfileAvatarProgressIndicator(),
                      _ when (_currentImage != null && _currentImage!.isNotEmpty) => ProfileAvatarWidget(
                          onTap: _openAvatarScreen,
                          imageUrl: _currentImage,
                        ),
                      _ => const ProfileStoreIcon(),
                    },
                  );
                },
              ),
            ),
            const SliverPadding(padding: kMaterialListPadding),
            SliverToBoxAdapter(
              child: ControllerBuilder(
                canRebuild: _canNameRebuild,
                controller: _relayController,
                builder: (context, state, child) {
                  VoidCallback? onTap = _openNameModal;
                  if (state is PendingState) onTap = null;
                  return ProfileNameWidget(
                    name: _currentName,
                    onTap: onTap,
                  );
                },
              ),
            ),
            const SliverPadding(padding: kMaterialListPadding),
            SliverToBoxAdapter(
              child: ControllerBuilder(
                controller: _relayController,
                canRebuild: _canContactsRebuild,
                builder: (context, state, child) {
                  VoidCallback? onTap = _onContactPressed;
                  if (state is PendingState) onTap = null;
                  return ProfileContactWidget(
                    phone: _currentContact,
                    onTap: onTap,
                  );
                },
              ),
            ),
            const SliverPadding(padding: kMaterialListPadding),
            SliverToBoxAdapter(
              child: ControllerBuilder(
                controller: _relayController,
                canRebuild: _canLocationRebuild,
                builder: (context, state, child) {
                  return ProfileLocationWidget(
                    location: _currentLocation?.title,
                    onTap: _openLocationScreen,
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
