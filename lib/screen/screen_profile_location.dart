import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:listenable_tools/listenable_tools.dart';

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

  LatLng? _placeToLatLng(Place? place) {
    if (place == null) return null;
    return LatLng(
      place.position!.coordinates![1],
      place.position!.coordinates![0],
    );
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;

    double bottom = context.mediaQuery.padding.bottom;
    await _mapController!.updateContentInsets(EdgeInsets.only(
      bottom: bottom + kBottomNavigationBarHeight * 3,
      right: 16.0,
      left: 16.0,
    ));

    if (_currentPlace == null) _goToMyPosition();
  }

  void _onMapIdle() {
    _myLocationController.value = false;
    _searchPlaceByPoint();
  }

  void _onMapMoved() {
    _bottomSheetController?.close();
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_currentPlace == null || _myLocationController.value) _goToPosition(location.position);
    _userLocation = location;
  }

  void _goToPosition(LatLng position, {double zoom = 18.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: zoom,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation != null) {
      _myLocationController.value = true;
      _goToPosition(_userLocation!.position);
      _searchPlaceByPoint(_userLocation!.position);
    }
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;
  Place? _currentPlace;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      return _animatePin();
    } else if (state case SuccessState<Place>(:final data)) {
      _currentPlace = data;
      _goToPosition(_placeToLatLng(_currentPlace)!);
    }
    return _resetPin();
  }

  void _searchPlaceByPoint([LatLng? center]) {
    center ??= _mapController!.cameraPosition!.target;
    _placeController.run(SearchPlaceEvent(position: (
      longitude: center.longitude,
      latitude: center.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      context.pop(_currentRelay);
    } else if (state case FailureState<String>(:final data)) {
      showSnackBar(
        context: context,
        text: switch (data) {
          _ => "Une erreur s'est produite",
        },
      );
    }
  }

  Future<void> _setRelay() {
    return _relayController.run(SetRelayEvent(
      location: _currentPlace,
      relay: _currentRelay,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.relay;
    _currentPlace = _currentRelay.location;
    _myLocationController = ValueNotifier(false);
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    /// PlaceService
    _placeController = AsyncController(switch (_currentPlace) {
      Place() => SuccessState<Place>(_currentPlace!),
      null => const InitState(),
    });

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

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    if (_userLocation != null) {
      final position = _userLocation!.position;
      final data = searchPlace(query: controller.text, position: (
        longitude: position.longitude,
        latitude: position.latitude,
      ));
      return data.then((places) {
        return places.map((item) {
          return ListTile(
            onTap: () {
              _placeController.value = SuccessState(item);
              Navigator.pop(context);
            },
            leading: const Icon(CupertinoIcons.location_solid),
            subtitle: Text(item.subtitle),
            title: Text(item.title),
          );
        });
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const ProfileLocationFloatingBackButton(),
          ValueListenableBuilder(
            valueListenable: _myLocationController,
            builder: (context, active, child) {
              return ProfileLocationFloatingLocationButton(
                onPressed: _goToMyPosition,
                active: active,
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ProfileLocationMap(
            onMapIdle: _onMapIdle,
            onMapMoved: _onMapMoved,
            onMapCreated: _onMapCreated,
            center: _placeToLatLng(_currentPlace),
            onUserLocationUpdated: _onUserLocationUpdated,
          ),
          ProfileLocationPin(
            controller: _pinAnimationController,
          ),
        ],
      ),
      bottomSheet: ControllerBuilder(
        listener: _listenPlaceState,
        controller: _placeController,
        builder: (context, placeState, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileLocationItemWidget(
                suggestionsBuilder: _suggestionsBuilder,
                title: switch (placeState) {
                  SuccessState<Place>(:final data) => data.title,
                  _ => null,
                },
              ),
              ControllerBuilder(
                listener: _listenRelayState,
                controller: _relayController,
                builder: (context, relayState, child) {
                  VoidCallback? onPressed = _setRelay;
                  if (relayState is PendingState) onPressed = null;
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
    );
  }
}
