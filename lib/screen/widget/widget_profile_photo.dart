import 'package:cached_network_image/cached_network_image.dart';
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
    final localizations = context.localizations;
    return AppBar(
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      leading: const Center(child: CustomBackButton()),
      title: Text(localizations.relaypointphoto.toUpperCase()),
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

class ProfilePhotoWidget extends StatelessWidget {
  const ProfilePhotoWidget({
    super.key,
    required this.imageUrl,
  });
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: imageUrl,
          placeholder: (context, url) {
            return const ProfileAvatarProgressIndicator();
          },
        ),
      ),
    );
  }
}
