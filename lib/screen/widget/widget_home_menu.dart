import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '_widget.dart';

class HomeMenuAppBar extends StatelessWidget {
  const HomeMenuAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      automaticallyImplyLeading: false,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w600),
      title: Text(localizations.menu.capitalize()),
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
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.relaypointprofile.capitalize()),
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
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.changephonenumber.capitalize()),
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
    final theme = context.theme;
    final localizations = context.localizations;
    return CustomListTile(
      onTap: () => onChanged(!value),
      title: Text(localizations.notifications.capitalize()),
      trailing: Switch(
        activeTrackColor: theme.colorScheme.onSurface,
        activeColor: theme.colorScheme.surface,
        onChanged: onChanged,
        value: value,
      ),
    );
  }
}

class HomeMenuTheme extends StatelessWidget {
  const HomeMenuTheme({
    super.key,
    this.onTap,
    required this.value,
  });
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.theme.capitalize()),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(value),
      ),
    );
  }
}

class HomeLanguageTheme extends StatelessWidget {
  const HomeLanguageTheme({
    super.key,
    this.onTap,
    required this.value,
  });
  final String? value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.language.capitalize()),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(value ?? localizations.system.capitalize()),
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
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.helporsuggestions.capitalize()),
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
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.shareapp.capitalize()),
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
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      textColor: CupertinoColors.destructiveRed,
      splashColor: CupertinoColors.destructiveRed.withOpacity(0.12),
      title: Text(localizations.logout.capitalize()),
      trailing: Visibility(
        visible: onTap == null,
        child: const CustomProgressIndicator(
          color: CupertinoColors.destructiveRed,
          radius: 6.0,
        ),
      ),
    );
  }
}

class HomeMenuNotifisModal extends StatelessWidget {
  const HomeMenuNotifisModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 1.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      contentTextStyle: theme.textTheme.bodyLarge,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
      titlePadding: const EdgeInsets.only(
        bottom: 16.0,
        right: 24.0,
        left: 24.0,
        top: 24.0,
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(localizations.enablenotification.capitalize()),
      ),
      content: Text(localizations.disablednotification.capitalize()),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
          onPressed: Navigator.of(context).pop,
          child: Text(localizations.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.0),
            child: Text(localizations.open.toUpperCase()),
          ),
        ),
      ],
    );
  }
}


class HomeMenuModal<T> extends StatefulWidget {
  const HomeMenuModal({
    super.key,
    required this.title,
    required this.values,
    required this.selected,
    required this.formatted,
    required this.onSelected,
  });

  final String title;

  final T? selected;
  final List<T> values;
  final String Function(T value) formatted;
  final ValueChanged<T> onSelected;

  @override
  State<HomeMenuModal<T>> createState() => _HomeMenuModalState<T>();
}

class _HomeMenuModalState<T> extends State<HomeMenuModal<T>> {
  late T? _selected;
  late List<T> _values;

  ValueChanged<bool?> _onChanged(T item) {
    return (_) {
      widget.onSelected(item);
      setState(() => _selected = item);
    };
  }

  @override
  void initState() {
    super.initState();

    _values = widget.values;
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 1.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(widget.title),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: List.of(_values.map((item) {
            return CheckboxListTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              checkboxShape: const CircleBorder(),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              value: _selected == item,
              onChanged: _onChanged(item),
              title: Text(widget.formatted(item).capitalize()),
            );
          })),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
          onPressed: Navigator.of(context).pop,
          child: Text(localizations.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.0),
            child: Text(localizations.apply.toUpperCase()),
          ),
        ),
      ],
    );
  }
}

class HomeMenuThemeModal<T> extends StatelessWidget {
  const HomeMenuThemeModal({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return HomeMenuModal<ThemeMode>(
      formatted: (value) => value.format(context),
      title: localizations.theme.capitalize(),
      values: ThemeMode.values,
      onSelected: onSelected,
      selected: selected,
    );
  }
}

class HomeMenuLanguageModal<T> extends StatelessWidget {
  const HomeMenuLanguageModal({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final ValueChanged<Locale> onSelected;
  final Locale? selected;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    const system = Locale('system');
    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);
    supportedLocales.insert(0, system);
    return HomeMenuModal<Locale>(
      title: localizations.language.capitalize(),
      formatted: (value) => value.format(context),
      selected: selected ?? system,
      values: supportedLocales,
      onSelected: onSelected,
    );
  }
}

class HomeMenuSupportModal extends StatelessWidget {
  const HomeMenuSupportModal({
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
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
        title: Text(localizations.helporsuggestions.capitalize()),
        actions: const [CustomCloseButton()],
      ),
      body: CustomScrollView(
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

class HomeMenuSupportEmailWidget extends StatelessWidget {
  const HomeMenuSupportEmailWidget({
    super.key,
    required this.onTap,
    required this.email,
  });
  final VoidCallback? onTap;
  final String email;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      leading: const Icon(Icons.email, size: 20.0),
      title: Text(localizations.email.capitalize()),
      trailing: Text(email),
    );
  }
}

class HomeMenuSupportWhatsappWidget extends StatelessWidget {
  const HomeMenuSupportWhatsappWidget({
    super.key,
    required this.onTap,
    required this.phone,
  });
  final VoidCallback? onTap;
  final String phone;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      leading: const Icon(Icons.wechat),
      title: Text(localizations.whatsapp.capitalize()),
      trailing: Text(phone),
    );
  }
}

class HomeMenuLogoutModal extends StatelessWidget {
  const HomeMenuLogoutModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 1.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
      titlePadding: const EdgeInsets.only(
        bottom: 16.0,
        right: 24.0,
        left: 24.0,
        top: 24.0,
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(localizations.logout.capitalize()),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
          onPressed: Navigator.of(context).pop,
          child: Text(localizations.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: CupertinoColors.destructiveRed,
              fontWeight: FontWeight.w600,
            ),
            child: Text(localizations.logout.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
