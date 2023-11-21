import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '_screen.dart';

class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({
    super.key,
    required this.image,
  });
  final Uint8List? image;
  static const imageKey = 'image';
  static const name = 'profile-photo';
  static const path = 'photo';
  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  /// Assets

  void _onEditPressed() async {
    final data = await openImageEditorModal(
      context: context,
    );

    if (data != null && mounted) {
      context.pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfilePhotoAppBar(
        actions: [
          ProfilePhotoEditButton(
            onPressed: _onEditPressed,
          ),
        ],
      ),
      body: InteractiveViewer(
        child: Center(
          child: Visibility(
            visible: widget.image != null,
            replacement: const ProfilePhotoStoreWidget(),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
