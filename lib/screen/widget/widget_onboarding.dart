import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_widget.dart';

class OnBoardingPermissionModal extends StatelessWidget {
  const OnBoardingPermissionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 1.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      titlePadding: const EdgeInsets.only(
        bottom: 16.0,
        right: 24.0,
        left: 24.0,
        top: 24.0,
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(localizations.open.toUpperCase()),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: Navigator.of(context).pop,
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontFamily: FontFamily.avenir,
            ),
            child: Text(localizations.cancel.toUpperCase()),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontFamily: FontFamily.avenir,
              fontWeight: FontWeight.w600,
            ),
            child: Text(localizations.open.toUpperCase()),
          ),
        ),
      ],
    );
  }
}

class OnBoardingSubmittedButton extends StatelessWidget {
  const OnBoardingSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.onboarding.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20.0,
                  sigmaY: 20.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        titleTextStyle: theme.textTheme.displaySmall!.copyWith(
                          fontFamily: FontFamily.avenirNext,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          wordSpacing: 1.0,
                        ),
                        subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
                          color: CupertinoColors.systemGrey4,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        title: const Text("GAGNEZ PLUS AVEC VOS POINTS RELAIS"),
                        subtitle: const Text("Rendez plus visibles vos points relais au près de vos client(e)s et gagnez plus."),
                      ),
                      Padding(padding: kMaterialListPadding * 4),
                      CustomSubmittedButton(
                        onPressed: onPressed,
                        child: Text(localizations.getstarted.toUpperCase()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
