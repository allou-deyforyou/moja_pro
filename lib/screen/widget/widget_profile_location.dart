import 'package:lottie/lottie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class ProfileLocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileLocationAppBar({
    super.key,
    required this.middle,
    required this.trailing,
  });
  final Widget middle;
  final Widget trailing;
  @override
  Size get preferredSize => const Size.fromHeight(74.0);
  @override
  Widget build(BuildContext context) {
    final style = switch (MediaQuery.platformBrightnessOf(context)) {
      Brightness.light => SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      Brightness.dark => SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    };
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: style,
        sized: false,
        child: SizedBox.fromSize(
          size: preferredSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ProfileLocationBackButton(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: middle,
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileLocationBackButton extends StatelessWidget {
  const ProfileLocationBackButton({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        elevation: 2.0,
        surfaceTintColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.onInverseSurface,
      ),
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      icon: const Icon(CupertinoIcons.arrow_left),
      onPressed: onPressed ?? Navigator.of(context).maybePop,
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
    return ClipPath(
      clipper: const ShapeBorderClipper(shape: StadiumBorder()),
      child: Material(
        elevation: 2.0,
        shape: const StadiumBorder(),
        color: theme.colorScheme.onInverseSurface,
        surfaceTintColor: theme.colorScheme.primaryContainer,
        child: SearchAnchor.bar(
          viewElevation: 0.0,
          barHintText: "Rechercher...",
          suggestionsBuilder: suggestionsBuilder,
          barElevation: const MaterialStatePropertyAll(0.0),
          viewBackgroundColor: theme.scaffoldBackgroundColor,
          barBackgroundColor: const MaterialStatePropertyAll(Colors.transparent),
          constraints: const BoxConstraints.tightFor(height: kMinInteractiveDimension),
          barLeading: const Icon(CupertinoIcons.search),
          viewLeading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(CupertinoIcons.arrow_left),
          ),
        ),
      ),
    );
  }
}

class ProfileLocationButton extends StatelessWidget {
  const ProfileLocationButton({
    super.key,
    this.value = false,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  VoidCallback? _onPressed() {
    if (onChanged == null) return null;
    return () => onChanged?.call(!value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        elevation: 2.0,
        surfaceTintColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.onInverseSurface,
      ),
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      icon: Visibility(
        visible: value,
        replacement: const Icon(CupertinoIcons.location),
        child: const Icon(CupertinoIcons.location_fill),
      ),
      onPressed: _onPressed(),
    );
  }
}

class ProfileLocationMap extends StatelessWidget {
  const ProfileLocationMap({
    super.key,
    this.onMapIdle,
    this.onMapClick,
    this.onMapActive,
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
  final VoidCallback? onMapActive;
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

  ValueChanged<PointerDownEvent>? _onMapActive() {
    if (onMapActive == null) return null;
    return (_) => onMapActive?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeepAlive(
      child: Listener(
        onPointerUp: _onMapIdle(),
        onPointerDown: _onMapActive(),
        child: MaplibreMap(
          compassEnabled: false,
          onMapClick: onMapClick,
          trackCameraPosition: true,
          onMapCreated: onMapCreated,
          onCameraIdle: onCameraIdle,
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

class ProfileLocationItemWidget extends StatelessWidget {
  const ProfileLocationItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        ListTile(
          title: const Text("Adresse du point relais"),
          titleTextStyle: theme.textTheme.titleLarge!.copyWith(
            color: theme.colorScheme.inverseSurface,
          ),
        ),
        const Divider(),
        ListTile(
          titleTextStyle: theme.textTheme.titleMedium,
          leading: const Icon(CupertinoIcons.location_solid),
          title: Text(title),
          subtitle: Text(subtitle),
        )
      ],
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
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 12.0, bottom: 12.0),
      child: CustomSubmittedButton(
        onPressed: onPressed,
        child: const Text("Définir"),
      ),
    );
  }
}
