import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class ProfileLocationAppBar extends StatelessWidget {
  const ProfileLocationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AppBar(
      titleSpacing: 0.0,
      toolbarHeight: 64.0,
      backgroundColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      leading: const Center(child: CustomBackButton()),
      title: const Text("Adresse du point relais"),
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class ProfileLocationMap extends StatelessWidget {
  const ProfileLocationMap({
    super.key,
    this.onMapIdle,
    this.onMapClick,
    this.onMapMoved,
    this.onCameraIdle,
    this.onMapCreated,
    this.onMapLongClick,
    this.initialCameraPosition,
    this.onUserLocationUpdated,
    this.onStyleLoadedCallback,
    this.myLocationEnabled = true,
  });

  final bool myLocationEnabled;
  final VoidCallback? onMapIdle;
  final VoidCallback? onMapMoved;
  final VoidCallback? onCameraIdle;
  final OnMapClickCallback? onMapClick;
  final MapCreatedCallback? onMapCreated;
  final OnMapClickCallback? onMapLongClick;
  final VoidCallback? onStyleLoadedCallback;
  final CameraPosition? initialCameraPosition;
  final OnUserLocationUpdated? onUserLocationUpdated;

  ValueChanged<PointerUpEvent>? _onMapIdle() {
    if (onMapIdle == null) return null;
    return (_) => onMapIdle?.call();
  }

  ValueChanged<PointerDownEvent>? _onMapMoved() {
    if (onMapMoved == null) return null;
    return (_) => onMapMoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeepAlive(
      child: Listener(
        onPointerUp: _onMapIdle(),
        onPointerDown: _onMapMoved(),
        child: MaplibreMap(
          compassEnabled: false,
          onMapClick: onMapClick,
          trackCameraPosition: true,
          onCameraIdle: onCameraIdle,
          onMapCreated: onMapCreated,
          onMapLongClick: onMapLongClick,
          myLocationEnabled: myLocationEnabled,
          onUserLocationUpdated: onUserLocationUpdated,
          onStyleLoadedCallback: onStyleLoadedCallback ?? () {},
          gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
          initialCameraPosition: initialCameraPosition ?? const CameraPosition(target: LatLng(0.0, 0.0)),
          styleString: 'https://api.maptiler.com/maps/86f5df0b-f809-4e6f-b8f0-9d3e0976fe90/style.json?key=ohdDnBihXL3Yk2cDRMfO',
        ),
      ),
    );
  }
}

class ProfileLocationPin extends StatelessWidget {
  const ProfileLocationPin({
    super.key,
    required this.controller,
  });
  final Animation<double> controller;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 50.0,
        child: Transform.scale(
          scale: 4.0,
          child: LottieBuilder.asset(
            Assets.images.lottiePin,
            controller: controller,
            fit: BoxFit.contain,
            animate: false,
          ),
        ),
      ),
    );
  }
}

class ProfileLocationSearchBar extends CustomAppBar {
  const ProfileLocationSearchBar({
    super.key,
    required this.suggestionsBuilder,
  });
  final SuggestionsBuilder suggestionsBuilder;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SearchAnchor(
      viewElevation: 0.0,
      suggestionsBuilder: suggestionsBuilder,
      viewBackgroundColor: theme.scaffoldBackgroundColor,
      viewHintText: MaterialLocalizations.of(context).searchFieldLabel.capitalize(),
      viewLeading: IconButton(
        onPressed: Navigator.of(context).pop,
        icon: const Icon(CupertinoIcons.arrow_left),
      ),
      builder: (context, controller) {
        return FloatingActionButton.small(
          elevation: 1.0,
          onPressed: controller.openView,
          backgroundColor: theme.colorScheme.surface,
          child: const Icon(CupertinoIcons.search),
        );
      },
    );
  }
}

class ProfileLocationItemWidget extends StatelessWidget {
  const ProfileLocationItemWidget({
    super.key,
    this.title,
    this.subtitle,
  });
  final String? title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final child = ListTile(
      titleTextStyle: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
      leading: const Icon(CupertinoIcons.location_solid),
      title: Text(title ?? 'Chargement...'),
      subtitle: Text(subtitle ?? 'Adresse'),
    );

    return Visibility(
      visible: title != null || subtitle != null,
      replacement: Shimmer.fromColors(
        baseColor: theme.colorScheme.onSurfaceVariant,
        highlightColor: theme.colorScheme.onInverseSurface,
        child: child,
      ),
      child: child,
    );
  }
}

class ProfileLocationSubmittedButton extends StatelessWidget {
  const ProfileLocationSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomSubmittedButton(
          onPressed: onPressed,
          child: const Text("Définir"),
        ),
      ),
    );
  }
}
