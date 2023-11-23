import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w600),
      leading: const Center(child: CustomBackButton()),
      title: Text(localizations.relaypointprofile.capitalize()),
    );
  }
}

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({
    super.key,
    required this.onEdit,
    required this.onTap,
  });
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Badge(
        largeSize: 35.0,
        alignment: const Alignment(0.8, 1.0),
        label: CupertinoButton(
          minSize: 0.0,
          onPressed: onEdit,
          padding: const EdgeInsets.all(2.0),
          child: Icon(
            color: theme.colorScheme.onTertiary,
            CupertinoIcons.pencil,
          ),
        ),
        child: CupertinoButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceVariant,
            radius: 80.0,
            child: Icon(
              Icons.storefront,
              color: theme.colorScheme.onSurfaceVariant,
              size: 100.0,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      contentPadding: kTabLabelPadding.copyWith(right: 2.0, top: 8.0),
      titleTextStyle: theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      subtitleTextStyle: theme.textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w500,
      ),
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        onPressed: onTap,
        icon: Visibility(
          visible: onTap != null,
          replacement: const CustomProgressIndicator(),
          child: const Icon(CupertinoIcons.pen, size: 20.0),
        ),
      ),
    );
  }
}

class ProfileNameWidget extends StatelessWidget {
  const ProfileNameWidget({
    super.key,
    required this.name,
    required this.onTap,
  });
  final String name;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return ProfileItemWidget(
      onTap: onTap,
      label: localizations.name.capitalize(),
      value: name,
    );
  }
}

class ProfileContactWidget extends StatelessWidget {
  const ProfileContactWidget({
    super.key,
    required this.phone,
    required this.onTap,
  });
  final String phone;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return ProfileItemWidget(
      onTap: onTap,
      label: localizations.contact.capitalize(),
      value: phone,
    );
  }
}

class ProfileLocationWidget extends StatelessWidget {
  const ProfileLocationWidget({
    super.key,
    required this.location,
    required this.onTap,
  });
  final String location;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return ProfileItemWidget(
      onTap: onTap,
      label: localizations.location.capitalize(),
      value: location,
    );
  }
}

class ProfileEditModal extends StatefulWidget {
  const ProfileEditModal({
    super.key,
    required this.hint,
    required this.label,
    required this.value,
    required this.keyboardType,
  });

  final String hint;
  final String label;
  final String value;

  final TextInputType keyboardType;

  @override
  State<ProfileEditModal> createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends State<ProfileEditModal> {
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;

  void _setupData() {
    _focusNode = FocusNode();
    _textEditingController = TextEditingController(text: widget.value);
    _textEditingController.selection = TextSelection(
      extentOffset: widget.value.length,
      baseOffset: 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _setupData();
  }

  @override
  void didUpdateWidget(covariant ProfileEditModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _setupData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 1.0,
      alignment: Alignment.bottomCenter,
      backgroundColor: theme.colorScheme.surface,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      insetPadding: kTabLabelPadding.copyWith(bottom: 16.0),
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
      titlePadding: const EdgeInsets.only(bottom: 16.0, right: 24.0, left: 24.0, top: 24.0),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(widget.label),
      ),
      content: TextFormField(
        autofocus: true,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        controller: _textEditingController,
        style: const TextStyle(fontSize: 18.0),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: widget.hint),
        onFieldSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
          onPressed: Navigator.of(context).pop,
          child: Text(localizations.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _textEditingController.text),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.bold),
            child: Text(localizations.edit.toUpperCase()),
          ),
        ),
      ],
    );
  }
}

class ProfileEditNameModal extends StatelessWidget {
  const ProfileEditNameModal({
    super.key,
    required this.name,
  });
  final String name;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return ProfileEditModal(
      keyboardType: TextInputType.name,
      label: localizations.editname.capitalize(),
      hint: localizations.relaypointname,
      value: name,
    );
  }
}

class ProfileEditContactModal extends StatelessWidget {
  const ProfileEditContactModal({
    super.key,
    required this.contact,
  });
  final String contact;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return ProfileEditModal(
      keyboardType: TextInputType.phone,
      label: localizations.editcontact.capitalize(),
      hint: localizations.relaypointcontact,
      value: contact,
    );
  }
}
