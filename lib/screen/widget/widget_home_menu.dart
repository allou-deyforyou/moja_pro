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
      backgroundColor: theme.colorScheme.surface,
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
        child: Text(localizations.menu.capitalize()),
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
    return ListTile(
      onTap: onTap,
      textColor: CupertinoColors.destructiveRed,
      splashColor: CupertinoColors.destructiveRed.withOpacity(0.12),
      contentPadding: kTabLabelPadding.copyWith(top: 8.0, bottom: 8.0),
      title: Text(localizations.logout.capitalize()),
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
  });

  final String title;

  final T? selected;
  final List<T> values;
  final String Function(T value) formatted;

  @override
  State<HomeMenuModal<T>> createState() => _HomeMenuModalState<T>();
}

class _HomeMenuModalState<T> extends State<HomeMenuModal<T>> {
  late T? _selected;
  late List<T> _values;

  ValueChanged<bool?> _onChanged(T value) {
    return (_) {
      setState(() => _selected = value);
    };
  }

  @override
  void initState() {
    super.initState();

    _values = widget.values;
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(covariant HomeMenuModal<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected || oldWidget.values != widget.values) {
      _values = widget.values;
      _selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AlertDialog(
      elevation: 0.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titlePadding: const EdgeInsets.only(
        bottom: 16.0,
        right: 24.0,
        left: 24.0,
        top: 24.0,
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: FontFamily.comfortaa,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 24.0,
          ),
          child: Text(widget.title),
        ),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
            child: Text(localizations.change.toUpperCase()),
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
  });
  final ThemeMode selected;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return HomeMenuModal<ThemeMode>(
      formatted: (value) => value.format(context),
      title: localizations.changetheme.capitalize(),
      values: ThemeMode.values,
      selected: selected,
    );
  }
}

class HomeMenuLanguageModal<T> extends StatelessWidget {
  const HomeMenuLanguageModal({
    super.key,
    required this.selected,
  });
  final Locale? selected;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    const system = Locale('system');
    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);
    supportedLocales.add(system);
    return HomeMenuModal<Locale>(
      title: localizations.changelanguage.capitalize(),
      formatted: (value) => value.format(context),
      selected: selected ?? system,
      values: supportedLocales,
    );
  }
}
