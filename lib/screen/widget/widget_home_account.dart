import 'package:flutter/material.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

import '_widget.dart';

class HomeAccountAppBar extends StatelessWidget {
  const HomeAccountAppBar({
    super.key,
    required this.title,
    required this.leading,
  });
  final Widget title;
  final Widget leading;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      leadingWidth: 64.0,
      leading: Center(child: leading),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: title,
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
    return Center(
      child: IntrinsicWidth(
        child: TextField(
          autofocus: true,
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontWeight: FontWeight.w100,
            letterSpacing: -0.8,
            wordSpacing: 4.0,
            fontSize: 34.0,
          ),
          inputFormatters: [
            ThousandsFormatter(
              formatter: defaultNumberFormat,
            ),
          ],
          decoration: const InputDecoration(
            filled: false,
            suffixIcon: Text("francs"),
            hintText: "Montant",
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
      label: Text("${amount.formatted} f"),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding.copyWith(top: 26.0, bottom: 26.0),
          child: CustomSubmittedButton(
            onPressed: onPressed,
            child: Text("Modifier".toUpperCase()),
          ),
        ),
      ],
    );
  }
}
