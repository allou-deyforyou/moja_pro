import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:extended_image/extended_image.dart';

import '_widget.dart';

class ProfileAvatarAppBar extends CustomAppBar {
  const ProfileAvatarAppBar({
    super.key,
    required this.onConfirm,
  });
  final VoidCallback? onConfirm;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return AppBar(
      centerTitle: true,
      title: Text(localizations.edit.capitalize()),
      leading: const Center(child: CustomCloseButton()),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(localizations.ok.toUpperCase()),
        ),
      ],
    );
  }
}

class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({
    super.key,
    required this.image,
    required this.imageEditorKey,
  });
  final Uint8List image;
  final Key? imageEditorKey;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ExtendedImage.memory(
      image,
      cacheRawData: true,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: imageEditorKey,
      initEditorConfigHandler: (state) {
        return EditorConfig(
          maxScale: 8.0,
          hitTestSize: 20.0,
          cornerColor: theme.colorScheme.tertiary,
          cropRectPadding: const EdgeInsets.all(10.0),
          editorMaskColorHandler: (context, isMasked) {
            return theme.colorScheme.surface;
          },
        );
      },
    );
  }
}

class ProfileAvatarNavigationBar extends StatelessWidget {
  const ProfileAvatarNavigationBar({
    super.key,
    this.onTap,
  });
  final ValueChanged<int>? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return DefaultTabController(
      length: 4,
      child: TabBar(
        onTap: onTap,
        labelPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurface,
        overlayColor: MaterialStatePropertyAll(theme.colorScheme.onSurface.withOpacity(0.12)),
        tabs: [
          Tab(
            icon: const Icon(CupertinoIcons.arrow_left_right_square_fill),
            text: localizations.flip.capitalize(),
          ),
          Tab(
            icon: const Icon(CupertinoIcons.rotate_left_fill),
            text: localizations.rotateleft.capitalize(),
          ),
          Tab(
            icon: const Icon(CupertinoIcons.rotate_right_fill),
            text: localizations.rotateright.capitalize(),
          ),
          Tab(
            icon: const Icon(CupertinoIcons.refresh_circled_solid),
            text: localizations.reset.capitalize(),
          ),
        ],
      ),
    );
  }
}
