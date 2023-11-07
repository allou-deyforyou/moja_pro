import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

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
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      toolbarHeight: 64.0,
      leading: leading,
      title: const Text(
        "Moja Pro",
        style: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: [trailing],
    );
  }
}

class HomeBarsFilledButton extends StatelessWidget {
  const HomeBarsFilledButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
        icon: const Icon(CupertinoIcons.bars, size: 28.0),
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
    required this.onReorder,
    required this.itemCount,
    required this.itemBuilder,
  });
  final ReorderCallback onReorder;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SliverReorderableGrid(
      onReorder: onReorder,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1.4,
        mainAxisSpacing: 16.0,
        mainAxisExtent: 130.0,
      ),
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 12.0,
          borderRadius: BorderRadius.circular(26.0),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final child = itemBuilder(context, index);
        return ReorderableGridDragStartListener(
          key: child.key,
          index: index,
          child: child,
        );
      },
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
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        elevation: 0.8,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        backgroundColor: theme.colorScheme.onInverseSurface,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26.0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              name.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.0,
              ),
            ),
            trailing: const CircleAvatar(
              backgroundColor: Colors.black,
              radius: 14.0,
            ),
          ),
          const Spacer(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Solde",
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.0,
                fontSize: 12.0,
              ),
            ),
            subtitle: Visibility(
              visible: amount != null,
              child: Builder(builder: (context) {
                return Text(
                  defaultNumberFormat.format(amount),
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
