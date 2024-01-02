import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

import '_widget.dart';

class HomeAccountSliverAppBar extends StatelessWidget {
  const HomeAccountSliverAppBar({
    super.key,
    required this.cash,
    required this.name,
    required this.image,
  });
  final bool? cash;
  final String name;
  final String image;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      leadingWidth: 64.0,
      toolbarHeight: 64.0,
      backgroundColor: theme.colorScheme.surface,
      leading: HomeAccountAvatarWrapper(
        content: HomeAccountAvatarWidget(
          imageUrl: image,
        ),
      ),
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        wordSpacing: 1.5,
      ),
      title: Visibility(
        visible: cash != null && cash!,
        replacement: Text(name.toUpperCase(), softWrap: false),
        child: Text(localizations.cash.toUpperCase(), softWrap: false),
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeAccountAvatarWrapper extends StatelessWidget {
  const HomeAccountAvatarWrapper({
    super.key,
    required this.content,
  });
  final Widget content;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: SizedBox.square(
        dimension: 20.0 * 2,
        child: Material(
          shape: CircleBorder(
            side: BorderSide(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.surfaceVariant,
          child: content,
        ),
      ),
    );
  }
}

class HomeAccountAvatarProgressIndicator extends StatelessWidget {
  const HomeAccountAvatarProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomProgressIndicator(
        strokeWidth: 4.0,
        radius: 35.0,
      ),
    );
  }
}

class HomeAccountAvatarWidget extends StatelessWidget {
  const HomeAccountAvatarWidget({
    super.key,
    required this.imageUrl,
  });
  final String? imageUrl;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageUrl!,
      placeholder: (context, url) {
        return const HomeAccountAvatarProgressIndicator();
      },
    );
  }
}

class HomeAccountBalanceTextField extends StatelessWidget {
  const HomeAccountBalanceTextField({
    super.key,
    required this.controller,
    required this.currency,
  });
  final TextEditingController controller;
  final String? currency;
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
            suffixIcon: Text(currency ?? 'f'),
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
