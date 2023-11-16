import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeMenuAppBar extends StatelessWidget {
  const HomeMenuAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(color: theme.colorScheme.outline),
      ),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: const Text("Menu"),
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeMenuProfile extends StatelessWidget {
  const HomeMenuProfile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: const Text("Profil"),
    );
  }
}

class HomeMenuEditPhone extends StatelessWidget {
  const HomeMenuEditPhone({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: const Text("Changer de numéro"),
    );
  }
}

class HomeMenuNotifs extends StatelessWidget {
  const HomeMenuNotifs({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: () => onChanged(!value),
      title: const Text("Notifications"),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class HomeMenuTheme extends StatelessWidget {
  const HomeMenuTheme({
    super.key,
    this.onTap,
    required this.trailing,
  });
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: const Text("Theme"),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: trailing,
      ),
    );
  }
}

class HomeMenuSupport extends StatelessWidget {
  const HomeMenuSupport({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: const Text("Aide ou Suggestion"),
    );
  }
}

class HomeMenuShare extends StatelessWidget {
  const HomeMenuShare({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: const Text("Inviter un contact"),
    );
  }
}

class HomeMenuLogout extends StatelessWidget {
  const HomeMenuLogout({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      textColor: CupertinoColors.destructiveRed,
      splashColor: CupertinoColors.destructiveRed.withOpacity(0.12),
      contentPadding: kTabLabelPadding.copyWith(top: 8.0, bottom: 8.0),
      title: const Text("Déconnexion"),
    );
  }
}
