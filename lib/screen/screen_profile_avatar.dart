import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_editor/image_editor.dart';
import 'package:extended_image/extended_image.dart';

import '_screen.dart';

class ProfileAvatarScreen extends StatefulWidget {
  const ProfileAvatarScreen({
    super.key,
    required this.image,
  });
  final Uint8List image;
  static const imageKey = 'image';
  static const name = 'profile-avatar';
  static const path = 'avatar';
  @override
  State<ProfileAvatarScreen> createState() => _ProfileAvatarScreenState();
}

class _ProfileAvatarScreenState extends State<ProfileAvatarScreen> {
  /// Assets
  late final GlobalKey<ExtendedImageEditorState> _imageEditorKey;

  void _onFlip() {
    _imageEditorKey.currentState!.flip();
  }

  void _onRotateLeft() {
    _imageEditorKey.currentState!.rotate(right: false);
  }

  void _onRotateRight() {
    _imageEditorKey.currentState!.rotate(right: true);
  }

  void _onReset() {
    _imageEditorKey.currentState!.reset();
  }

  void _editImage() async {
    final state = _imageEditorKey.currentState!;
    final action = state.editAction!;
    final option = ImageEditorOption();
    if (action.needCrop) option.addOption(ClipOption.fromRect(state.getCropRect()!));
    if (action.hasRotateAngle) option.addOption(RotateOption(action.rotateAngle.toInt()));
    if (action.needFlip) option.addOption(FlipOption(horizontal: action.flipY, vertical: action.flipX));
    option.outputFormat = const OutputFormat.png(88);
    final result = await ImageEditor.editImageAndGetFile(imageEditorOption: option, image: state.rawImageData);
    if (mounted) Navigator.pop(context, result.path);
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        _onFlip();
        break;
      case 1:
        _onRotateLeft();
        break;
      case 2:
        _onRotateRight();
        break;
      case 3:
        _onReset();
        break;
    }
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
      appBar: ProfileAvatarAppBar(
        onConfirm: () {},
      ),
      body: ProfileAvatarEditor(
        imageEditorKey: _imageEditorKey,
        image: widget.image,
      ),
      bottomNavigationBar: ProfileAvatarNavigationBar(
        onTap: _onTap,
      ),
    );
  }
}
