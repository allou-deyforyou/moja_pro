import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class AuthSignupAppBar extends StatelessWidget {
  const AuthSignupAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w600),
      leading: const Center(child: CustomBackButton()),
      title: Text(localizations.createrelaypoint.capitalize()),
    );
  }
}

class AuthSignupFullnameTextField extends StatelessWidget {
  const AuthSignupFullnameTextField({
    super.key,
    required this.controller,
  });
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Padding(
      padding: kTabLabelPadding,
      child: TextFormField(
        autofocus: false,
        controller: controller,
        keyboardType: TextInputType.name,
        style: const TextStyle(fontSize: 18.0),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: localizations.relaypointname,
        ),
      ),
    );
  }
}

class AuthSignupWeekdayListView extends StatelessWidget {
  const AuthSignupWeekdayListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      controller: PrimaryScrollController.maybeOf(context),
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 8.0);
      },
      itemBuilder: itemBuilder,
    );
  }
}

class AuthSignupContinueButton extends StatelessWidget {
  const AuthSignupContinueButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SafeArea(
      child: Padding(
        padding: kTabLabelPadding.copyWith(top: 16.0, bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomSubmittedButton(
              onPressed: onPressed,
              child: Text(localizations.completed.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthSignupWeekdayListTile extends StatefulWidget {
  const AuthSignupWeekdayListTile({
    super.key,
    required this.title,
    required this.onChanged,
    required this.dateTimeRange,
  });
  final Widget title;
  final (DateTime?, DateTime?) dateTimeRange;
  final ValueChanged<(DateTime?, DateTime?)> onChanged;

  @override
  State<AuthSignupWeekdayListTile> createState() => _AuthSignupWeekdayListTileState();
}

class _AuthSignupWeekdayListTileState extends State<AuthSignupWeekdayListTile> {
  late (DateTime?, DateTime?) _dateTimeRange;
  int? _isOpened;
  @override
  void initState() {
    super.initState();
    _dateTimeRange = widget.dateTimeRange;
    _isOpened = null;
  }

  @override
  void didUpdateWidget(covariant AuthSignupWeekdayListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateTimeRange != widget.dateTimeRange) {
      _dateTimeRange = widget.dateTimeRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final endDateTime = _dateTimeRange.$2;
    final startDateTime = _dateTimeRange.$1;
    final active = startDateTime != null && endDateTime != null;
    var currentDateTime = _isOpened == 0 ? _dateTimeRange.$1 : _dateTimeRange.$2;
    currentDateTime ??= DateTime(0);
    void onSelected([int? index]) => setState(() => _isOpened = index);
    return TapRegion(
      onTapOutside: (_) => onSelected(),
      child: CupertinoListSection.insetGrouped(
        dividerMargin: 0.0,
        margin: EdgeInsets.zero,
        additionalDividerMargin: 0.0,
        separatorColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        decoration: BoxDecoration(color: active ? colorScheme.secondaryContainer : colorScheme.surfaceVariant),
        children: [
          ListTile(
            selected: active,
            textColor: colorScheme.onSurfaceVariant,
            selectedColor: colorScheme.onSecondaryContainer,
            title: widget.title,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  showCheckmark: false,
                  selected: _isOpened == 0,
                  selectedColor: colorScheme.secondary,
                  onSelected: (selected) => onSelected(selected ? 0 : null),
                  labelStyle: _isOpened == 0 ? TextStyle(color: colorScheme.onSecondary) : null,
                  label: startDateTime != null ? Text(TimeOfDay.fromDateTime(startDateTime).format(context)) : const Text('--:--'),
                ),
                const SizedBox(width: 12.0),
                ChoiceChip(
                  showCheckmark: false,
                  selected: _isOpened == 1,
                  selectedColor: colorScheme.secondary,
                  onSelected: (selected) => onSelected(selected ? 1 : null),
                  labelStyle: _isOpened == 1 ? TextStyle(color: colorScheme.onSecondary) : null,
                  label: endDateTime != null ? Text(TimeOfDay.fromDateTime(endDateTime).format(context)) : const Text('--:--'),
                ),
              ],
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
              visible: _isOpened != null,
              key: ValueKey(_isOpened),
              child: SizedBox(
                height: 130.0,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(hours: currentDateTime.hour, minutes: currentDateTime.minute),
                  onTimerDurationChanged: (duration) {
                    final value = DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds);
                    setState(() {
                      _dateTimeRange = (
                        _isOpened == 0 ? value : startDateTime,
                        _isOpened == 1 ? value : endDateTime,
                      );
                    });
                    widget.onChanged(_dateTimeRange);
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
