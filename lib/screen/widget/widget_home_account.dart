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
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        height: 1.0,
      ),
      title: Text(
        textAlign: TextAlign.center,
        name.toUpperCase(),
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeAccountBalanceTextField extends StatelessWidget {
  const HomeAccountBalanceTextField({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            wordSpacing: 0.0,
            fontSize: 34.0,
          ),
          inputFormatters: [
            ThousandsFormatter(
              formatter: defaultNumberFormat,
            ),
          ],
          decoration: InputDecoration(
            filled: false,
            suffixIcon: const Text("francs"),
            hintText: localizations.balance,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class HomeAccountSuggestionListView extends StatelessWidget {
  const HomeAccountSuggestionListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 14.0);
        },
      ),
    );
  }
}

class HomeAccountSuggestionItemWidget extends StatelessWidget {
  const HomeAccountSuggestionItemWidget({
    super.key,
    required this.amount,
    required this.onPressed,
  });

  final double amount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      label: DefaultTextStyle.merge(
        style: const TextStyle(height: 1.0),
        child: Text("${amount.formatted} f"),
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
