import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
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
  late ValueNotifier<bool> _myLocationController;
  late AnimationController _pinAnimationController;
  late ValueNotifier<double?> _pinVisibilityController;
  PersistentBottomSheetController? _bottomSheetController;
  late Relay _currentRelay;

  Future<void> _loadPin() async {
    _pinAnimationController.value = 0.6;
    _pinAnimationController.repeat(min: 0.7, max: 0.8);
  }

  Future<void> _startPin() async {
    _pinAnimationController.value = 0.1;
    await _pinAnimationController.animateTo(0.4);
  }

  Future<void> _stopPin() async {
    await _pinAnimationController.animateTo(0.0);
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
  LatLng? _centerPosition;

  late double _mapPadding;
  double? _bearing;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;
  }

  Future<void> _onStyleLoadedCallback() async {
    _pinVisibilityController.value = _mapPadding;

    await Future.wait([
      _updateContentInsets(),
    ]);
  }

  Future<void> _updateContentInsets() {
    return _mapController!.updateContentInsets(EdgeInsets.only(
      bottom: _mapPadding,
      right: 16.0,
      left: 16.0,
    ));
  }

  void _onMapIdle() async {
    await _stopPin();
    _centerPosition = _mapController!.cameraPosition!.target;

    _searchPlace(_centerPosition!);
  }

  void _onMapMoved() {
    _startPin();

    _myLocationController.value = false;
    _bottomSheetController?.close();
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_currentPlace == null && _userLocation == null) {
      _goToMyPosition(location);
    } else if (_myLocationController.value) {
      _goToPosition(location.position);
    }

    _userLocation = location;
  }

  void _goToPosition(LatLng position) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        bearing: _bearing ?? 0.0,
        target: position,
        tilt: 60.0,
        zoom: 18.0,
      )),
    );
  }

  void _goToMyPosition([UserLocation? position]) async {
    position ??= _userLocation;
    if (position == null) return;

    _myLocationController.value = true;

    _bearing = position.bearing ?? 0.0;
    _centerPosition = position.position;

    _goToPosition(_centerPosition!);

    _searchPlace(_centerPosition!);
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;
  Place? _currentPlace;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      _loadPin();
    } else {
      if (state case SuccessState<Place>(:final data)) {
        _currentPlace = data;
      }

      _resetPin();
    }
  }

  void _searchPlace(LatLng position) {
    _placeController.run(SearchPlaceEvent(position: (
      longitude: position.longitude,
      latitude: position.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<Relay>(:var data)) {
      _currentRelay = data;
      _currentPlace = _currentRelay.location;
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
    _pinVisibilityController = ValueNotifier(null);
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = context.mediaQuery;
    final bottom = mediaQuery.padding.bottom;
    _mapPadding = bottom + kBottomNavigationBarHeight * 3.0;
    _pinVisibilityController.value = _mapPadding;
  }

  @override
  void dispose() {
    /// Assets
    _pinAnimationController.dispose();
    _myLocationController.dispose();

    super.dispose();
  }

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    if (_userLocation == null || controller.text.isEmpty) return const [];

    final position = _userLocation!.position;
    final data = searchPlace(query: controller.text, position: (
      longitude: position.longitude,
      latitude: position.latitude,
    ));
    return data.then((places) {
      return places.map((item) {
        return LocationItemWidget(
          onTap: () {
            _myLocationController.value = false;
            _placeController.value = SuccessState(item);
            _goToPosition(_placeToLatLng(item)!);
            Navigator.pop(context);
          },
          subtitle: item.subtitle,
          title: item.title,
        );
      });
    });
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
            onStyleLoadedCallback: _onStyleLoadedCallback,
            onUserLocationUpdated: _onUserLocationUpdated,
          ),
          ValueListenableBuilder<double?>(
            valueListenable: _pinVisibilityController,
            builder: (context, padding, child) {
              return Visibility(
                key: ValueKey(padding),
                visible: padding != null,
                child: Builder(
                  builder: (context) {
                    return Positioned.fill(
                      bottom: padding,
                      child: ProfileLocationPin(
                        controller: _pinAnimationController,
                      ),
                    );
                  },
                ),
              );
            },
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
