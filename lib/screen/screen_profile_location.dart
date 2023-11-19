import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:widget_tools/widget_tools.dart';
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
  late BuildContext _scaffoldContext;

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
  }

  void _animatePin() {
    _pinAnimationController.repeat(min: 0.15, max: 1.0);
  }

  void _resetPin() {
    _pinAnimationController.reset();
  }

  void _onMyLocationChanged(bool value) {
    _myLocationController.value = value;
    _goToMyPosition();
  }

  FutureOr<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) {
    return [];
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;

  void _onMapIdle() {
    _myLocationController.value = false;
    final center = _mapController!.cameraPosition!.target;
    _searchPlaceByPosition(center);
  }

  void _onMapActive() {
    _bottomSheetController?.close();
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    _goToMyPosition();
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_userLocation == null) _goToPosition(location.position);
    _userLocation = location;
    _goToMyPosition();
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
    if (_userLocation != null && _myLocationController.value) {
      _goToPosition(_userLocation!.position);
    }
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      return _animatePin();
    } else if (state case SuccessState<Place>(:var data)) {
      _showLocationBottomSheet(data);
    }
    _resetPin();
  }

  void _searchPlaceByPosition(LatLng center) {
    _placeController.run(SearchPlace(position: (
      longitude: center.longitude,
      latitude: center.latitude,
    )));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _myLocationController = ValueNotifier(true);
    _pinAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    /// PlaceService
    _placeController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _pinAnimationController.dispose();
    _myLocationController.dispose();

    super.dispose();
  }

  void _showLocationBottomSheet(Place place) async {
    _bottomSheetController = showBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileLocationItemWidget(
              subtitle: place.subtitle,
              title: place.title,
            ),
            ProfileLocationSubmittedButton(
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      listener: _listenPlaceState,
      controller: _placeController,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: ProfileLocationAppBar(
          middle: ProfileLocationSearchBar(
            suggestionsBuilder: _suggestionsBuilder,
          ),
          trailing: ValueListenableBuilder(
            valueListenable: _myLocationController,
            builder: (context, value, child) {
              return ProfileLocationButton(
                onChanged: _onMyLocationChanged,
                value: value,
              );
            },
          ),
        ),
        body: AfterLayout(
          afterLayout: _afterLayout,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProfileLocationMap(
                onUserLocationUpdated: _onUserLocationUpdated,
                onMapCreated: _onMapCreated,
                onMapActive: _onMapActive,
                onMapIdle: _onMapIdle,
              ),
              ProfileLocationPin(
                controller: _pinAnimationController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
