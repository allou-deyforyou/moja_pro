import 'package:flutter/material.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class AuthSigninAppBar extends StatelessWidget {
  const AuthSigninAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      leading: const Center(child: CustomBackButton()),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: Text(localizations.confirm.capitalize()),
      ),
    );
  }
}

class AuthSignupCodePinTextField extends StatelessWidget {
  const AuthSignupCodePinTextField({
    super.key,
    required this.controller,
  });
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Padding(
      padding: kTabLabelPadding,
      child: TextFormField(
        autofocus: true,
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          hintText: localizations.code,
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),
    );
  }
}

class AuthSigninResendButton extends StatelessWidget {
  const AuthSigninResendButton({
    super.key,
    this.onPressed,
    required this.timeout,
  });
  final Duration timeout;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      padding: kTabLabelPadding,
      alignment: Alignment.centerRight,
      child: CounterBuilder(
        reverse: true,
        timeout: timeout,
        child: Text(localizations.resendcode.toUpperCase()),
        builder: (context, duration, child) {
          final done = duration == Duration.zero;
          return TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
            ),
            onPressed: done ? onPressed : null,
            child: Visibility(
              visible: onPressed != null,
              replacement: const CustomProgressIndicator(),
              child: Visibility(
                visible: done,
                replacement: Text('$duration'.substring(0, 7)),
                child: child!,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AuthSigninSubmittedButton extends StatelessWidget {
  const AuthSigninSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SafeArea(
      child: Padding(
        padding: kTabLabelPadding.copyWith(top: 16.0, bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomSubmittedButton(
              onPressed: onPressed,
              child: Text(localizations.completed.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}
