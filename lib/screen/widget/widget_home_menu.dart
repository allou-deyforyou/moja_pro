import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeMenuAppBar extends StatelessWidget {
  const HomeMenuAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Text("Menu"),
      actions: [CustomCloseButton()],
    );
  }
}

class HomeMenuProfileListTile extends StatelessWidget {
  const HomeMenuProfileListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      title: const Text("Profil"),
    );
  }
}

class HomeMenuEditPhoneListTile extends StatelessWidget {
  const HomeMenuEditPhoneListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      title: const Text("Changer de numéro"),
    );
  }
}

class HomeMenuNotifsListTile extends StatelessWidget {
  const HomeMenuNotifsListTile({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: kTabLabelPadding,
      onTap: () => onChanged(!value),
      title: const Text("Notifications"),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class HomeMenuThemeListTile extends StatelessWidget {
  const HomeMenuThemeListTile({
    super.key,
    this.onTap,
    required this.trailing,
  });
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      title: const Text("Theme"),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: trailing,
      ),
    );
  }
}

class HomeMenuSupportListTile extends StatelessWidget {
  const HomeMenuSupportListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      title: const Text("Aide ou Suggestion"),
    );
  }
}

class HomeMenuShareListTile extends StatelessWidget {
  const HomeMenuShareListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      title: const Text("Inviter un contact"),
    );
  }
}

class HomeMenuLogoutListTile extends StatelessWidget {
  const HomeMenuLogoutListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: kTabLabelPadding,
      textColor: CupertinoColors.destructiveRed,
      splashColor: CupertinoColors.destructiveRed.withOpacity(0.12),
      title: const Text("Déconnexion"),
    );
  }
}
