import 'package:flutter/material.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

import '_widget.dart';

class HomeAccountSliverAppBar extends StatelessWidget {
  const HomeAccountSliverAppBar({
    super.key,
    required this.name,
  });
  final String name;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      leadingWidth: 64.0,
      toolbarHeight: 64.0,
      backgroundColor: theme.colorScheme.surface,
      leading: const Center(child: CircleAvatar()),
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        wordSpacing: 1.5,
      ),
      title: Text(name.toUpperCase()),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeAccountBalanceTextField extends StatelessWidget {
  const HomeAccountBalanceTextField({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      alignment: Alignment.center,
      padding: kTabLabelPadding.copyWith(
        bottom: kMinInteractiveDimension,
        top: kMinInteractiveDimension,
      ),
      child: IntrinsicWidth(
        child: TextField(
          autofocus: true,
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: theme.textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.w200,
            letterSpacing: 1.0,
          ),
          inputFormatters: [
            ThousandsFormatter(
              formatter: defaultNumberFormat,
            ),
          ],
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            hintText: localizations.balance,
            focusedBorder: InputBorder.none,
            suffixIcon: const Text("francs"),
          ),
        ),
      ),
    );
  }
}

class HomeAccountSubmittedButton extends StatelessWidget {
  const HomeAccountSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding.copyWith(top: 26.0, bottom: 26.0),
          child: CustomSubmittedButton(
            onPressed: onPressed,
            child: Text(localizations.edit.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
