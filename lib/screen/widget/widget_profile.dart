import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      leading: const Center(child: CustomBackButton()),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: const Text("Profil"),
      ),
    );
  }
}

class ProfileFullnameTextField extends StatelessWidget {
  const ProfileFullnameTextField({
    super.key,
    required this.controller,
  });
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Nom complet"),
      textColor: context.theme.colorScheme.onSurfaceVariant,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: TextFormField(
          autofocus: false,
          controller: controller,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: "Nom complet",
          ),
        ),
      ),
    );
  }
}

class ProfileLocationTextField extends StatelessWidget {
  const ProfileLocationTextField({
    super.key,
    required this.onTap,
    required this.controller,
  });
  final VoidCallback? onTap;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Emplacement"),
      textColor: context.theme.colorScheme.onSurfaceVariant,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: TextFormField(
          onTap: onTap,
          readOnly: true,
          autofocus: false,
          controller: controller,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: "Emplacement",
          ),
        ),
      ),
    );
  }
}

class ProfileAvailabilityListView extends StatelessWidget {
  const ProfileAvailabilityListView({
    super.key,
    required this.children,
  });
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Disponibilité"),
      textColor: context.theme.colorScheme.onSurfaceVariant,
      subtitle: Wrap(spacing: 10.0, children: children),
    );
  }
}

class ProfileAvailabilityChip extends StatelessWidget {
  const ProfileAvailabilityChip({
    super.key,
    required this.label,
    this.selected = false,
    required this.onPressed,
  });

  final Widget label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: InputChip(
        selected: selected,
        showCheckmark: false,
        onPressed: onPressed,
        label: label,
      ),
    );
  }
}

class ProfileAvailabilityBottomSheet extends StatelessWidget {
  const ProfileAvailabilityBottomSheet({
    super.key,
    required this.title,
    required this.actions,
    required this.content,
  });

  final Widget title;
  final List<Widget> actions;

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          SliverAppBar.medium(
            pinned: true,
            centerTitle: false,
            toolbarHeight: 64.0,
            automaticallyImplyLeading: false,
            titleTextStyle: context.theme.textTheme.headlineLarge,
            title: title,
            actions: actions,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: content,
          ),
        ],
      ),
    );
  }
}

class ProfileAvailableActiveBotton extends StatelessWidget {
  const ProfileAvailableActiveBotton({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kTabLabelPadding,
      alignment: Alignment.center,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(padding: kTabLabelPadding),
        child: const Text("Activer"),
      ),
    );
  }
}

class ProfileAvailableTimeListTile extends StatefulWidget {
  const ProfileAvailableTimeListTile({
    super.key,
    required this.title,
    required this.onChanged,
    required this.dateTime,
  });
  final Widget title;
  final DateTime dateTime;
  final ValueChanged<DateTime?> onChanged;

  @override
  State<ProfileAvailableTimeListTile> createState() => _ProfileAvailableTimeListTileState();
}

class _ProfileAvailableTimeListTileState extends State<ProfileAvailableTimeListTile> {
  late DateTime _dateTime;
  late bool _isOpened;
  @override
  void initState() {
    super.initState();
    _dateTime = widget.dateTime;
    _isOpened = false;
  }

  @override
  void didUpdateWidget(covariant ProfileAvailableTimeListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateTime != widget.dateTime) {
      _dateTime = widget.dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    void onPressed() => setState(() => _isOpened = !_isOpened);
    return TapRegion(
      onTapOutside: (event) => setState(() => _isOpened = false),
      child: CupertinoListSection.insetGrouped(
        dividerMargin: 0.0,
        margin: kTabLabelPadding,
        additionalDividerMargin: 0.0,
        separatorColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer),
        children: [
          ListTile(
            onTap: onPressed,
            title: widget.title,
            textColor: theme.colorScheme.onSecondaryContainer,
            trailing: Chip(
              label: Text(TimeOfDay.fromDateTime(_dateTime).format(context)),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: Visibility(
              visible: _isOpened,
              key: ValueKey(_isOpened),
              child: SizedBox(
                height: 130.0,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(hours: _dateTime.hour, minutes: _dateTime.minute),
                  onTimerDurationChanged: (duration) {
                    widget.onChanged(DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvailableStartTimeListTile extends StatelessWidget {
  const ProfileAvailableStartTimeListTile({
    super.key,
    required this.onTap,
    required this.dateTime,
  });
  final DateTime dateTime;
  final ValueChanged<DateTime?> onTap;
  @override
  Widget build(BuildContext context) {
    return ProfileAvailableTimeListTile(
      title: const Text("Début du service"),
      dateTime: dateTime,
      onChanged: onTap,
    );
  }
}

class ProfileAvailableEndTimeListTile extends StatelessWidget {
  const ProfileAvailableEndTimeListTile({
    super.key,
    required this.onTap,
    required this.dateTime,
  });
  final DateTime dateTime;
  final ValueChanged<DateTime?> onTap;
  @override
  Widget build(BuildContext context) {
    return ProfileAvailableTimeListTile(
      title: const Text("Fin du service"),
      dateTime: dateTime,
      onChanged: onTap,
    );
  }
}

class ProfileSubmittedButton extends StatelessWidget {
  const ProfileSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomSubmittedButton(
        onPressed: onPressed,
        child: const Text("Modifier"),
      ),
    );
  }
}
