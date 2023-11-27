import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:permission_handler/permission_handler.dart';

import '_screen.dart';

class ProfileLocationScreen extends StatefulWidget {
  const ProfileLocationScreen({
    super.key,
    required this.relay,
  });
  final Relay relay;
  static const relayKey = 'relay';
  static const name = 'profile-location';
  static const path = 'location';
  @override
  State<ProfileLocationScreen> createState() => _ProfileLocationScreenState();
}

class _ProfileLocationScreenState extends State<ProfileLocationScreen> with TickerProviderStateMixin {
  /// Assets
  PersistentBottomSheetController? _bottomSheetController;
  late AnimationController _pinAnimationController;
  late ValueNotifier<bool> _myLocationController;
  late Relay _currentRelay;

  void _animatePin() {
    _pinAnimationController.repeat(min: 0.15, max: 1.0);
  }

  void _resetPin() {
    _pinAnimationController.reset();
  }

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    if (_userLocation != null) {
      final position = _userLocation!.position;
      final data = searchPlaceByQuery(query: controller.text, position: (
        position.longitude,
        position.latitude,
      ));
      return data.then((places) {
        return places.map((item) {
          return ListTile(
            onTap: () => controller.closeView(item.title),
            title: Text(item.title),
          );
        });
      });
    }
    return const [];
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;

  void _onMapIdle() {
    _myLocationController.value = false;
    final center = _mapController!.cameraPosition!.target;
    _searchPlaceByPoint(center);
  }

  void _onMapMoved() {
    _bottomSheetController?.close();
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    _goToMyPosition();
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_userLocation == null) _goToPosition(location.position);
    _userLocation = location;
    if (_myLocationController.value) _goToMyPosition();
  }

  void _goToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: 18.0,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation != null) {
      _myLocationController.value = true;
      _goToPosition(_userLocation!.position);
    }
  }

  /// PermissionService
  late AsyncController<AsyncState> _permissionController;

  void _listenPermissionState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _requestPermission();
    } else if (state is SuccessState<Permission>) {
      _goToMyPosition();
    } else if (state case FailureState<RequestPermissionEvent>(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _requestPermission() {
    return _permissionController.run(const RequestPermissionEvent(
      permission: Permission.locationWhenInUse,
    ));
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      return _animatePin();
    }
    return _resetPin();
  }

  void _searchPlaceByPoint(LatLng center) {
    _placeController.run(SearchPlaceEvent(position: (
      center.longitude,
      center.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      context.pop(_currentRelay);
    } else if (state case FailureState<SetRelayEvent>(:final code)) {
      showSnackbar(
        context: context,
        text: switch (code) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _setRelay({required Place place}) {
    return _relayController.run(SetRelayEvent(
      relay: _currentRelay,
      location: place,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.relay;
    _myLocationController = ValueNotifier(true);
    _pinAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    /// PermissionService
    _permissionController = AsyncController(const InitState());

    /// PlaceService
    _placeController = AsyncController(const InitState());

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _pinAnimationController.dispose();
    _myLocationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      autoListen: true,
      listener: _listenPermissionState,
      controller: _permissionController,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: SafeArea(
          top: false,
          child: Padding(
            padding: kTabLabelPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ProfileLocationFloatingBackButton(),
                ValueListenableBuilder(
                  valueListenable: _myLocationController,
                  builder: (context, active, child) {
                    return ProfileLocationFloatingLocationButton(
                      onChanged: (value) => _goToMyPosition(),
                      active: active,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ProfileLocationMap(
              onUserLocationUpdated: _onUserLocationUpdated,
              onMapCreated: _onMapCreated,
              onCameraIdle: _onMapIdle,
              onMapMoved: _onMapMoved,
            ),
            ProfileLocationPin(
              controller: _pinAnimationController,
            ),
          ],
        ),
        bottomSheet: SafeArea(
          top: false,
          child: ControllerConsumer(
            listener: _listenPlaceState,
            controller: _placeController,
            builder: (context, placeState, child) {
              Place? place;
              if (placeState case SuccessState<Place>(:final data)) {
                place = data;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileLocationItemWidget(
                    suggestionsBuilder: _suggestionsBuilder,
                    title: place?.title,
                  ),
                  ControllerConsumer(
                    listener: _listenRelayState,
                    controller: _relayController,
                    builder: (context, relayState, child) {
                      VoidCallback? onPressed = () {
                        _setRelay(place: place!);
                      };
                      if (relayState is PendingState) {
                        onPressed = null;
                      }
                      return ProfileLocationSubmittedButton(
                        disabled: placeState is PendingState,
                        onPressed: onPressed,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
