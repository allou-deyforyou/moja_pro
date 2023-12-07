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
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar.medium(
      leading: leading,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      title: Text(localizations.mybalances.toUpperCase()),
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
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.isEmpty) return theme.colorScheme.surface;
              return null;
            }),
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
      padding: kTabLabelPadding,
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
    required this.cash,
    required this.name,
    required this.amount,
    required this.onPressed,
  });
  final bool? cash;
  final String name;
  final double? amount;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;

    Color textColor = theme.colorScheme.onSurface;
    Color tileColor = theme.colorScheme.surfaceVariant;
    // if (cash != null && cash!) {
    //   textColor = theme.colorScheme.onSurface;
    //   tileColor = theme.colorScheme.surfaceVariant.withOpacity(0.4);
    // }
    return Stack(
      children: [
        ListTile(
          tileColor: tileColor,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            color: textColor,
            fontSize: 18.0,
          ),
          subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            fontSize: 20.0,
            height: 1.8,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          onTap: onPressed,
          title: Visibility(
            visible: cash != null && cash!,
            replacement: Text(name, softWrap: false),
            child: Text(localizations.cash, softWrap: false),
          ),
          subtitle: Text("${defaultNumberFormat.format(amount ?? 0)} f"),
        ),
        if (cash != null && cash!)
          const Positioned(
            right: 0.0,
            child: CornerBanner(
              bannerPosition: CornerBannerPosition.topRight,
              bannerColor: Colors.green,
              child: Text(
                style: TextStyle(color: Colors.white),
                "cash",
              ),
            ),
          ),
      ],
    );
  }
}
