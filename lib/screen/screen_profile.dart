import 'package:flutter/material.dart';
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

  void _openAvatarScreen() {
    context.pushNamed(ProfilePhotoScreen.name);
  }

  void _openEditorModal() async {
    await openImageEditorModal(
      context: context,
    );
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
      _currentRelay = _currentRelay.copyWith(name: data);
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
      _currentRelay = _currentRelay.copyWith(contacts: [data]);
      _setRelay(contacts: [data]);
    }
  }

  void _openLocationScreen() async {
    final data = await context.pushNamed<Relay>(ProfileLocationScreen.name, extra: {
      ProfileLocationScreen.relayKey: _currentRelay,
    });
    if (data != null) {
      _relayController.value = SuccessState(data);
    }
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      currentUser.value = currentUser.value?.copyWith(relays: [_currentRelay]);
    } else if (state case FailureState<SetRelayEvent>(:final code, :final event)) {
      _currentRelay = _currentRelay.copyWith(
        contacts: event?.contacts,
        name: event?.name,
      );

      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _setRelay({String? name, List<String>? contacts}) {
    return _relayController.run(SetRelayEvent(
      relay: _currentRelay,
      contacts: contacts,
      name: name,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = currentUser.value!.relays!.first;

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const ProfileAppBar(),
          const SliverPadding(padding: kMaterialListPadding),
          SliverToBoxAdapter(
            child: ProfileAvatarWidget(
              onTap: _openAvatarScreen,
              onEdit: _openEditorModal,
            ),
          ),
          const SliverPadding(padding: kMaterialListPadding),
          SliverToBoxAdapter(
            child: ControllerConsumer(
              listener: _listenRelayState,
              controller: _relayController,
              builder: (context, state, child) {
                VoidCallback? onTap = _openNameModal;
                if (state is PendingState) onTap = null;
                return ProfileNameWidget(
                  name: _currentRelay.name,
                  onTap: onTap,
                );
              },
            ),
          ),
          const SliverPadding(padding: kMaterialListPadding),
          SliverToBoxAdapter(
            child: ControllerBuilder(
              controller: _relayController,
              builder: (context, state, child) {
                VoidCallback? onTap = _onContactPressed;
                if (state is PendingState) onTap = null;
                return ProfileContactWidget(
                  phone: _currentRelay.contacts!.first,
                  onTap: onTap,
                );
              },
            ),
          ),
          const SliverPadding(padding: kMaterialListPadding),
          SliverToBoxAdapter(
            child: ControllerBuilder(
              controller: _relayController,
              builder: (context, state, child) {
                return ProfileLocationWidget(
                  location: _currentRelay.location!.title,
                  onTap: _openLocationScreen,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
