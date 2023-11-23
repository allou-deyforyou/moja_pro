import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:image_editor/image_editor.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '_widget.dart';

void showSnackbar({
  required BuildContext context,
  required String text,
  VoidCallback? onTry,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    action: onTry != null ? SnackBarAction(label: "RESSAYER", onPressed: onTry) : null,
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
    content: Text(text),
  ));
}

class DialogPage<T> extends Page<T> {
  const DialogPage({super.key, required this.child});
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return child;
      },
    );
  }
}

class CustomSubmittedButton extends StatelessWidget {
  const CustomSubmittedButton({
    super.key,
    this.timeout,
    required this.onPressed,
    required this.child,
  });
  final Duration? timeout;
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CounterBuilder(
      reverse: true,
      timeout: timeout ?? Duration.zero,
      child: child,
      builder: (context, duration, child) {
        final done = duration == Duration.zero;
        return FilledButton(
          onPressed: done ? onPressed : null,
          style: FilledButton.styleFrom(
            textStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.0),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          ),
          child: Container(
            height: 24.0,
            alignment: Alignment.center,
            child: Visibility(
              visible: onPressed != null,
              replacement: const CustomProgressIndicator(),
              child: Visibility(
                visible: done,
                replacement: Text('$duration'.substring(0, 7)),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.color,
    this.radius = 8.0,
    this.strokeWidth = 2.0,
  });
  final Color? color;
  final double radius;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.fromSize(
      size: Size.fromRadius(radius),
      child: CircularProgressIndicator(
        backgroundColor: theme.colorScheme.onInverseSurface,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.onDone,
    this.onError,
    required this.child,
    required this.callback,
  });
  final Widget child;
  final AsyncCallback callback;
  final bool Function()? onDone;
  final bool Function()? onError;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snapshot) {
            return switch (snapshot.connectionState) {
              ConnectionState.waiting => const CustomProgressIndicator(
                  strokeWidth: 4.0,
                  radius: 30.0,
                ),
              ConnectionState.done when widget.onError?.call() ?? snapshot.hasError => const Column(
                  children: [
                    Text("Une erreur s'est produite, lors du chargement..."),
                  ],
                ),
              ConnectionState.done when widget.onDone?.call() ?? snapshot.hasData => widget.child,
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.textColor,
    this.splashColor,
    this.onTap,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });
  final Color? textColor;
  final Color? splashColor;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      textColor: textColor,
      splashColor: splashColor,
      contentPadding: kTabLabelPadding.copyWith(top: 6.0, bottom: 6.0),
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        letterSpacing: 0.0,
        fontSize: 18.0,
      ),
      onTap: onTap,
      title: title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.arrow_left),
    );
  }
}

class CustomFilledBackButton extends StatelessWidget {
  const CustomFilledBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final canPop = onPressed != null || Navigator.of(context).canPop();
    return Visibility(
      visible: canPop,
      child: IconButton.filledTonal(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
        onPressed: onPressed ?? Navigator.of(context).maybePop,
        icon: const Icon(CupertinoIcons.arrow_left),
      ),
    );
  }
}

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.xmark),
    );
  }
}

Future<String?> openImageEditorModal({
  required BuildContext context,
}) async {
  final source = await showModalBottomSheet<picker.ImageSource>(
    context: context,
    builder: (context) {
      return ImageEditorModal(
        children: [
          ImageEditorCameraWidget(
            onTap: () => Navigator.pop(context, picker.ImageSource.camera),
          ),
          ImageEditorGaleryWidget(
            onTap: () => Navigator.pop(context, picker.ImageSource.gallery),
          ),
        ],
      );
    },
  );

  if (source != null) {
    final imagePicker = picker.ImagePicker();
    final file = await imagePicker.pickImage(source: source);

    if (file != null) {
      final image = await file.readAsBytes();
      // ignore: use_build_context_synchronously
      return Navigator.push<String>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return ImageEditorScreen(image: image);
          },
        ),
      );
    }
  }
  return null;
}

class ImageEditorModal extends StatelessWidget {
  const ImageEditorModal({
    super.key,
    required this.children,
  });
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 64.0,
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
        title: Text(localizations.editavatar.capitalize()),
        actions: const [CustomCloseButton()],
      ),
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          const SliverPadding(padding: kMaterialListPadding),
          SliverList.separated(
            itemCount: children.length,
            separatorBuilder: (context, index) {
              return Padding(padding: kMaterialListPadding / 2);
            },
            itemBuilder: (context, index) {
              return children[index];
            },
          ),
        ],
      ),
    );
  }
}

class ImageEditorCameraWidget extends StatelessWidget {
  const ImageEditorCameraWidget({
    super.key,
    required this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      leading: const Icon(CupertinoIcons.camera),
      title: Text(localizations.opencamera.capitalize()),
    );
  }
}

class ImageEditorGaleryWidget extends StatelessWidget {
  const ImageEditorGaleryWidget({
    super.key,
    required this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      leading: const Icon(CupertinoIcons.photo_on_rectangle),
      title: Text(localizations.opengallery.capitalize()),
    );
  }
}

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({
    super.key,
    required this.image,
  });
  final Uint8List image;
  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  /// Assets
  late final GlobalKey<ExtendedImageEditorState> _imageEditorKey;
  Future<void>? _imageFuture;

  Future<void> _onConfirm() async {
    final path = await _editImage();
    if (mounted) Navigator.pop(context, path);
  }

  Future<String> _editImage() async {
    final state = _imageEditorKey.currentState!;
    final action = state.editAction!;
    final option = ImageEditorOption();
    if (action.needCrop) option.addOption(ClipOption.fromRect(state.getCropRect()!));
    if (action.hasRotateAngle) option.addOption(RotateOption(action.rotateAngle.toInt()));
    if (action.needFlip) option.addOption(FlipOption(horizontal: action.flipY, vertical: action.flipX));
    option.outputFormat = const OutputFormat.png(88);
    final result = await ImageEditor.editImageAndGetFile(imageEditorOption: option, image: state.rawImageData);
    return result.path;
  }

  void _onFlip() {
    _imageEditorKey.currentState!.flip();
  }

  void _onRotate() {
    _imageEditorKey.currentState!.rotate(right: false);
  }

  void _onReset() {
    _imageEditorKey.currentState!.reset();
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _imageEditorKey = GlobalKey<ExtendedImageEditorState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      appBar: AppBar(toolbarHeight: 0.0),
      body: ImageEditorEditor(
        imageEditorKey: _imageEditorKey,
        image: widget.image,
      ),
      bottomNavigationBar: StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder<void>(
            future: _imageFuture,
            builder: (context, snapshot) {
              VoidCallback? onConfirm = () => setState(() {
                    _imageFuture = _onConfirm();
                  });
              if (snapshot.connectionState == ConnectionState.waiting) {
                onConfirm = null;
              }
              return ImageEditorNavigationBar(
                onConfirm: onConfirm,
                buttons: [
                  ImageEditorFlipButton(onPressed: _onFlip),
                  ImageEditorRotateButton(onPressed: _onRotate),
                  ImageEditorResetButton(onPressed: _onReset),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ImageEditorEditor extends StatelessWidget {
  const ImageEditorEditor({
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
          lineColor: theme.colorScheme.onBackground,
          cornerColor: theme.colorScheme.onBackground,
          cropRectPadding: const EdgeInsets.all(10.0),
          editorMaskColorHandler: (context, isMasked) {
            return theme.colorScheme.background.withOpacity(0.8);
          },
        );
      },
    );
  }
}

class ImageEditorNavigationBar extends StatelessWidget {
  const ImageEditorNavigationBar({
    super.key,
    required this.buttons,
    required this.onConfirm,
  });
  final List<Widget> buttons;
  final VoidCallback? onConfirm;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      color: theme.colorScheme.background,
      height: kMinInteractiveDimension * 1.2,
      child: SafeArea(
        top: false,
        child: NavigationToolbar(
          leading: CupertinoButton(
            padding: kTabLabelPadding,
            onPressed: Navigator.of(context).pop,
            child: DefaultTextStyle(
              style: theme.textTheme.labelMedium!,
              child: Text(localizations.cancel.toUpperCase()),
            ),
          ),
          middle: SizedBox(
            height: kMinInteractiveDimension,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buttons,
            ),
          ),
          trailing: CupertinoButton(
            onPressed: onConfirm,
            padding: kTabLabelPadding,
            child: DefaultTextStyle(
              style: theme.textTheme.labelMedium!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              child: Visibility(
                visible: onConfirm != null,
                replacement: const CustomProgressIndicator(radius: 6.0),
                child: Text(localizations.completed.toUpperCase()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageEditorFlipButton extends StatelessWidget {
  const ImageEditorFlipButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CupertinoButton(
      padding: kTabLabelPadding,
      onPressed: onPressed,
      child: Icon(
        CupertinoIcons.arrow_left_right_square_fill,
        color: theme.colorScheme.onSurface,
        size: 26.0,
      ),
    );
  }
}

class ImageEditorRotateButton extends StatelessWidget {
  const ImageEditorRotateButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CupertinoButton(
      padding: kTabLabelPadding.copyWith(bottom: 10.0, left: 24.0),
      onPressed: onPressed,
      child: Icon(
        CupertinoIcons.rotate_left_fill,
        color: theme.colorScheme.onSurface,
        size: 32.0,
      ),
    );
  }
}

class ImageEditorResetButton extends StatelessWidget {
  const ImageEditorResetButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CupertinoButton(
      padding: kTabLabelPadding,
      onPressed: onPressed,
      child: Icon(
        CupertinoIcons.refresh_circled_solid,
        color: theme.colorScheme.onSurface,
        size: 26.0,
      ),
    );
  }
}
