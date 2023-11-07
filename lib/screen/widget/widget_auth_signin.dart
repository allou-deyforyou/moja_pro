import 'package:flutter/material.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class AuthSigninAppBar extends StatelessWidget {
  const AuthSigninAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return const SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      leading: Center(child: CustomBackButton()),
      title: Text("Confirmer"),
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
    return Padding(
      padding: kTabLabelPadding,
      child: TextFormField(
        autofocus: true,
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Code",
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
    return Container(
      padding: kTabLabelPadding,
      alignment: Alignment.centerRight,
      child: CounterBuilder(
        reverse: true,
        timeout: timeout,
        child: const Text("Renvoyer le code"),
        builder: (context, duration, child) {
          final done = duration == Duration.zero;
          return TextButton(
            style: TextButton.styleFrom(
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
    return SafeArea(
      child: Padding(
        padding: kTabLabelPadding.copyWith(top: 16.0, bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomSubmittedButton(
              onPressed: onPressed,
              child: const Text("Terminé"),
            ),
          ],
        ),
      ),
    );
  }
}
