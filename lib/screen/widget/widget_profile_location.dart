import 'package:auto_size_text/auto_size_text.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class ProfileLocationFloatingBackButton extends CustomAppBar {
  const ProfileLocationFloatingBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FilledButton.tonal(
      onPressed: Navigator.of(context).pop,
      style: FilledButton.styleFrom(
        elevation: 0.12,
        shape: const StadiumBorder(),
        shadowColor: theme.colorScheme.surfaceTint,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: const Icon(CupertinoIcons.arrow_left),
    );
  }
}

class ProfileLocationFloatingLocationButton extends StatelessWidget {
  const ProfileLocationFloatingLocationButton({
    super.key,
    this.active = false,
    required this.onChanged,
  });
  final bool active;
  final ValueChanged<bool>? onChanged;
  VoidCallback? _onPressed() {
    if (onChanged == null) return null;
    return () => onChanged!(!active);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FilledButton.tonal(
      onPressed: _onPressed(),
      style: FilledButton.styleFrom(
        elevation: 0.12,
        shape: const StadiumBorder(),
        shadowColor: theme.colorScheme.surfaceTint,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: Visibility(
        visible: active,
        replacement: const Icon(CupertinoIcons.location),
        child: const Icon(CupertinoIcons.location_fill),
      ),
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

class ProfileLocationItemWidget extends StatelessWidget {
  const ProfileLocationItemWidget({
    super.key,
    this.title,
    required this.suggestionsBuilder,
  });
  final String? title;
  final SuggestionsBuilder suggestionsBuilder;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    final child = ListTile(
      contentPadding: kTabLabelPadding.copyWith(right: 2.0, top: 16.0, bottom: 28.0),
      titleTextStyle: theme.textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      leading: const Icon(CupertinoIcons.location_solid),
      title: Text(localizations.relaypointaddress.capitalize()),
      subtitle: SizedBox(
        height: 35.0,
        child: Visibility(
          visible: title != null,
          replacement: Text('${localizations.loading.capitalize()}...'),
          child: Builder(
            builder: (context) {
              return DefaultTextStyle.merge(
                style: TextStyle(color: theme.colorScheme.primary),
                child: AutoSizeText(title!, maxLines: 2),
              );
            },
          ),
        ),
      ),
      trailing: SearchAnchor(
        viewElevation: 0.0,
        suggestionsBuilder: suggestionsBuilder,
        viewBackgroundColor: theme.scaffoldBackgroundColor,
        viewHintText: MaterialLocalizations.of(context).searchFieldLabel.capitalize(),
        viewLeading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(CupertinoIcons.arrow_left),
        ),
        builder: (context, controller) {
          return IconButton(
            onPressed: controller.openView,
            icon: const Icon(CupertinoIcons.search),
          );
        },
      ),
    );
    return Visibility(
      visible: title != null,
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
    this.disabled = false,
    required this.onPressed,
  });
  final bool disabled;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            textStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.0),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          ),
          child: Visibility(
            visible: disabled || onPressed != null,
            replacement: const CustomProgressIndicator(),
            child: Text(localizations.define.toUpperCase()),
          ),
        ),
      ),
    );
  }
}
