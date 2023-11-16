import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeBarsButton extends StatelessWidget {
  const HomeBarsButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
        icon: const Icon(CupertinoIcons.bars, size: 34.0),
        onPressed: onPressed,
      ),
    );
  }
}

class HomeListTile extends StatelessWidget {
  const HomeListTile({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final Widget title;
  final Widget subtitle;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: FontFamily.comfortaa,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        fontSize: 28.0,
      ),
      child: const Text("Mes Soldes"),
    );
  }
}

class HomeAvailableSwitch extends StatelessWidget {
  const HomeAvailableSwitch({
    super.key,
    this.value = false,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      alignment: Alignment.centerLeft,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class HomeAccountSliverGridView extends StatelessWidget {
  const HomeAccountSliverGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: kTabLabelPadding.copyWith(top: 12.0, bottom: 12.0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          crossAxisSpacing: 18.0,
          childAspectRatio: 2.5,
          mainAxisSpacing: 18.0,
          mainAxisExtent: 80.0,
        ),
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
    );
  }
}

class HomeAccountCard extends StatelessWidget {
  const HomeAccountCard({
    super.key,
    required this.name,
    required this.amount,
    required this.onPressed,
  });
  final String name;
  final double? amount;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      titleTextStyle: theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onBackground,
        fontFamily: FontFamily.comfortaa,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        wordSpacing: 1.0,
      ),
      subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      onTap: onPressed,
      title: Text(name.toUpperCase()),
      subtitle: Text("${defaultNumberFormat.format(amount ?? 0)} f"),
    );
  }
}
