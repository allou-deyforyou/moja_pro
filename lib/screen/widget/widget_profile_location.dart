import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      padding: kTabLabelPadding.copyWith(top: 16.0),
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
      padding: kTabLabelPadding.copyWith(top: 16.0),
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
  late SystemUiOverlayStyle _barStyle;

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
    switch (CupertinoTheme.brightnessOf(context)) {
      case Brightness.light:
        _mapStyle = 'https://api.maptiler.com/maps/streets-v2/style.json?key=ohdDnBihXL3Yk2cDRMfO';
        _barStyle = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);
        break;
      case Brightness.dark:
        _mapStyle = 'https://api.maptiler.com/maps/streets-v2-dark/style.json?key=ohdDnBihXL3Yk2cDRMfO';
        _barStyle = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeepAlive(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        sized: false,
        value: _barStyle,
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
            myLocationRenderMode: switch (defaultTargetPlatform) {
              TargetPlatform.iOS => MyLocationRenderMode.COMPASS,
              _ => MyLocationRenderMode.GPS,
            },
            onUserLocationUpdated: widget.onUserLocationUpdated,
            onStyleLoadedCallback: widget.onStyleLoadedCallback ?? () {},
            initialCameraPosition: switch (widget.center) {
              null => const CameraPosition(target: LatLng(0.0, 0.0)),
              _ => CameraPosition(
                  target: widget.center!,
                  tilt: 60.0,
                  zoom: 18.0,
                ),
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
            Assets.images.mylocation,
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
            icon: const Icon(CupertinoIcons.pen),
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

class LocationItemWidget extends StatelessWidget {
  const LocationItemWidget({
    super.key,
    this.onTap,
    this.subtitle,
    required this.title,
  });
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      onTap: onTap,
      leading: const Icon(CupertinoIcons.location_solid),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      title: Text(title),
    );
  }
}
