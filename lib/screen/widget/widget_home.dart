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
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: SliverPadding(
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
    required this.currency,
    required this.onPressed,
  });
  final bool? cash;
  final String name;
  final double? amount;
  final String? currency;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Stack(
      children: [
        ListTile(
          tileColor: theme.colorScheme.surfaceVariant,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
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
          subtitle: Text.rich(TextSpan(
            children: [
              TextSpan(text: defaultNumberFormat.format(amount)),
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Text(
                  currency ?? 'f',
                  style: const TextStyle(fontSize: 10.0),
                ),
              ),
            ],
          )),
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

class HomeDisabledLocationModal extends StatelessWidget {
  const HomeDisabledLocationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomModal(
      title: Text(localizations.relaypointaddress.toUpperCase()),
      content: const Text("Pour être en ligne et visible, définissez l'emplacement de votre point relais."),
      actions: [
        const CustomModalCancelAction(),
        CustomModalConfirmAction(text: localizations.define.capitalize()),
      ],
    );
  }
}
