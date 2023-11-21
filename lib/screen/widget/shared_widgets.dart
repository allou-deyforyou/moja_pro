import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class DialogPage<T> extends Page<T> {
  const DialogPage({super.key, required this.child});
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return child;
      },
    );
  }
}

class CustomSubmittedButton extends StatelessWidget {
  const CustomSubmittedButton({
    super.key,
    this.timeout,
    required this.onPressed,
    required this.child,
  });
  final Duration? timeout;
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CounterBuilder(
      reverse: true,
      timeout: timeout ?? Duration.zero,
      child: child,
      builder: (context, duration, child) {
        final done = duration == Duration.zero;
        return FilledButton(
          onPressed: done ? onPressed : null,
          style: FilledButton.styleFrom(
            textStyle: theme.textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              height: 1.0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          ),
          child: Container(
            height: 24.0,
            alignment: Alignment.center,
            child: Visibility(
              visible: onPressed != null,
              replacement: const CustomProgressIndicator(),
              child: Visibility(
                visible: done,
                replacement: Text('$duration'.substring(0, 7)),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.color,
    this.radius = 10.0,
    this.strokeWidth = 2.0,
  });
  final Color? color;
  final double radius;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.fromSize(
      size: Size.fromRadius(radius),
      child: CircularProgressIndicator(
        backgroundColor: theme.colorScheme.onInverseSurface,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.onDone,
    this.onError,
    required this.child,
    required this.callback,
  });
  final Widget child;
  final AsyncCallback callback;
  final bool Function()? onDone;
  final bool Function()? onError;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snapshot) {
            return switch (snapshot.connectionState) {
              ConnectionState.waiting => const CustomProgressIndicator(
                  strokeWidth: 4.0,
                  radius: 30.0,
                ),
              ConnectionState.done when widget.onError?.call() ?? snapshot.hasError => const Column(
                  children: [
                    Text("Une erreur s'est produite, lors du chargement..."),
                  ],
                ),
              ConnectionState.done when widget.onDone?.call() ?? snapshot.hasData => widget.child,
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.onTap,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: kTabLabelPadding.copyWith(top: 8.0, bottom: 8.0),
      onTap: onTap,
      title: title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.arrow_left),
    );
  }
}

class CustomFilledBackButton extends StatelessWidget {
  const CustomFilledBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final canPop = onPressed != null || Navigator.of(context).canPop();
    return Visibility(
      visible: canPop,
      child: IconButton.filledTonal(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
        onPressed: onPressed ?? Navigator.of(context).maybePop,
        icon: const Icon(CupertinoIcons.arrow_left),
      ),
    );
  }
}

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.xmark),
    );
  }
}
