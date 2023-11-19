import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({
    super.key,
    required this.leading,
    required this.trailing,
  });
  final Widget leading;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SliverAppBar.medium(
      leading: leading,
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: Text(localizations.mybalances.capitalize()),
      ),
      actions: [trailing],
    );
  }
}

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
    final theme = context.theme;
    final localizations = context.localizations;
    return Row(
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12.0,
          ),
          child: Visibility(
            visible: value,
            replacement: Text(localizations.offline.toUpperCase()),
            child: Text(localizations.online.toUpperCase()),
          ),
        ),
        const SizedBox(width: 6.0),
        Transform.scale(
          scale: 0.85,
          alignment: Alignment.centerLeft,
          child: Switch(
            activeTrackColor: CupertinoColors.activeGreen.resolveFrom(context),
            trackOutlineColor: MaterialStateProperty.resolveWith((states) {
              if (states.isEmpty) return theme.colorScheme.onSurface;
              return null;
            }),
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.isEmpty) return theme.colorScheme.onSurface;
              return null;
            }),
            activeColor: CupertinoColors.white,
            onChanged: onChanged,
            value: value,
          ),
        ),
      ],
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
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onBackground,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        wordSpacing: 1.0,
      ),
      subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        wordSpacing: 0.0,
        fontSize: 18.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      onTap: onPressed,
      title: Text(name.toUpperCase()),
      subtitle: Text("${defaultNumberFormat.format(amount ?? 0)} f"),
    );
  }
}
