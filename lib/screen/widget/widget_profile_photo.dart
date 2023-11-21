import 'package:flutter/material.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class ProfilePhotoAppBar extends CustomAppBar {
  const ProfilePhotoAppBar({
    super.key,
    required this.actions,
  });
  final List<Widget> actions;
  @override
  Size get preferredSize => const Size.fromHeight(64.0);
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AppBar(
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w600),
      leading: const Center(child: CustomBackButton()),
      title: const Text("Photo de point relais"),
      actions: actions,
    );
  }
}

class ProfilePhotoEditButton extends StatelessWidget {
  const ProfilePhotoEditButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return TextButton(
      onPressed: onPressed,
      child: Text(localizations.edit.toUpperCase()),
    );
  }
}

class ProfilePhotoStoreWidget extends StatelessWidget {
  const ProfilePhotoStoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      height: 300.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Icon(
        Icons.storefront,
        color: theme.colorScheme.onSurfaceVariant,
        size: 150.0,
      ),
    );
  }
}
