import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.shape = const StadiumBorder(),
  });

  final Widget? child;
  final OutlinedBorder? shape;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: shape,
        elevation: 0.12,
        shadowColor: theme.colorScheme.surfaceTint,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: child,
    );
  }
}

class ProfileLocationFloatingBackButton extends CustomAppBar {
  const ProfileLocationFloatingBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 8.0),
      child: HomeButton(
        onPressed: Navigator.of(context).pop,
        child: const Icon(CupertinoIcons.arrow_left),
      ),
    );
  }
}

class ProfileLocationFloatingLocationButton extends StatelessWidget {
  const ProfileLocationFloatingLocationButton({
    super.key,
    this.active = false,
    required this.onPressed,
  });
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 6.0),
      child: HomeButton(
        onPressed: onPressed,
        child: Visibility(
          visible: active,
          replacement: const Icon(CupertinoIcons.location),
          child: const Icon(CupertinoIcons.location_fill),
        ),
      ),
    );
  }
}

class ProfileLocationMap extends StatefulWidget {
  const ProfileLocationMap({
    super.key,
    this.center,
    this.onMapIdle,
    this.onMapClick,
    this.onMapMoved,
    this.onCameraIdle,
    this.onMapCreated,
    this.onMapLongClick,
    this.onUserLocationUpdated,
    this.onStyleLoadedCallback,
    this.myLocationEnabled = true,
  });

  final LatLng? center;
  final bool myLocationEnabled;
  final VoidCallback? onMapIdle;
  final VoidCallback? onMapMoved;
  final VoidCallback? onCameraIdle;
  final OnMapClickCallback? onMapClick;
  final MapCreatedCallback? onMapCreated;
  final OnMapClickCallback? onMapLongClick;
  final VoidCallback? onStyleLoadedCallback;
  final OnUserLocationUpdated? onUserLocationUpdated;

  @override
  State<ProfileLocationMap> createState() => _ProfileLocationMapState();
}

class _ProfileLocationMapState extends State<ProfileLocationMap> {
  late String _mapStyle;

  ValueChanged<PointerUpEvent>? _onMapIdle() {
    if (widget.onMapIdle == null) return null;
    return (_) => widget.onMapIdle?.call();
  }

  ValueChanged<PointerDownEvent>? _onMapMoved() {
    if (widget.onMapMoved == null) return null;
    return (_) => widget.onMapMoved?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapStyle = switch (CupertinoTheme.brightnessOf(context)) {
      Brightness.light => 'https://api.maptiler.com/maps/streets-v2/style.json?key=ohdDnBihXL3Yk2cDRMfO',
      Brightness.dark => 'https://api.maptiler.com/maps/streets-v2-dark/style.json?key=ohdDnBihXL3Yk2cDRMfO',
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = switch (CupertinoTheme.brightnessOf(context)) {
      Brightness.light => SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      Brightness.dark => SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    };
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: style,
      child: CustomKeepAlive(
        child: Listener(
          onPointerUp: _onMapIdle(),
          onPointerDown: _onMapMoved(),
          child: MaplibreMap(
            compassEnabled: false,
            styleString: _mapStyle,
            trackCameraPosition: true,
            onMapClick: widget.onMapClick,
            onCameraIdle: widget.onCameraIdle,
            onMapCreated: widget.onMapCreated,
            onMapLongClick: widget.onMapLongClick,
            myLocationEnabled: widget.myLocationEnabled,
            onUserLocationUpdated: widget.onUserLocationUpdated,
            onStyleLoadedCallback: widget.onStyleLoadedCallback ?? () {},
            gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
            initialCameraPosition: switch (widget.center) {
              null => const CameraPosition(target: LatLng(0.0, 0.0)),
              _ => CameraPosition(target: widget.center!, zoom: 18.0),
            },
          ),
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
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      leading: const Icon(CupertinoIcons.location_solid),
      title: Text(localizations.relaypointaddress.toUpperCase()),
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
    final localizations = context.localizations;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomSubmittedButton(
          onPressed: onPressed,
          child: Text(localizations.define.toUpperCase()),
        ),
      ),
    );
  }
}
