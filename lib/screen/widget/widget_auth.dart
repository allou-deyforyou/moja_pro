import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '_widget.dart';

class AuthAppBar extends StatelessWidget {
  const AuthAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      leading: const Center(child: CustomBackButton()),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: FontFamily.comfortaa,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 28.0,
        ),
        child: Text(localizations.login.capitalize()),
      ),
    );
  }
}

class AuthEditPhoneAppBar extends StatelessWidget {
  const AuthEditPhoneAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return SliverAppBar.medium(
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
        child: Text(localizations.changephonenumber.capitalize()),
      ),
    );
  }
}

class AuthDialCodeButton extends StatelessWidget {
  const AuthDialCodeButton({
    super.key,
    required this.countryCode,
    required this.dialCode,
    required this.onPressed,
  });
  final String? dialCode;
  final String? countryCode;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: theme.textTheme.titleLarge!.copyWith(
          fontSize: 18.0,
        ),
        foregroundColor: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      onPressed: onPressed,
      icon: Text("${CustomString.toFlag(countryCode ?? '--')} ${dialCode ?? '--'}"),
      label: const Icon(CupertinoIcons.chevron_down, size: 18.0),
    );
  }
}

class AuthPhoneTextField extends StatelessWidget {
  const AuthPhoneTextField({
    super.key,
    this.autofocus = false,
    required this.controller,
    required this.prefixIcon,
  });
  final bool autofocus;
  final Widget prefixIcon;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Padding(
      padding: kTabLabelPadding,
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          hintText: localizations.phonenumber,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}

class AuthSubmittedButton extends StatelessWidget {
  const AuthSubmittedButton({
    super.key,
    this.timeout,
    required this.onPressed,
  });
  final Duration? timeout;
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
              timeout: timeout,
              onPressed: onPressed,
              child: Text(localizations.next.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCountryModal<T> extends StatefulWidget {
  const AuthCountryModal({
    super.key,
    this.initialValue,
    this.valueFormatted,
    required this.values,
  });
  final List<T> values;
  final T? initialValue;
  final String Function(T value)? valueFormatted;
  @override
  State<AuthCountryModal<T>> createState() => _AuthCountryModalState<T>();
}

class _AuthCountryModalState<T> extends State<AuthCountryModal<T>> {
  /// Assets
  FixedExtentScrollController? _scrollController;
  late List<T> _values;
  T? _currentValue;

  String _defaultValueFormatted(T value) {
    return widget.valueFormatted?.call(value) ?? value.toString();
  }

  void _onSelectedItemChanged(int index) {
    _currentValue = _values[index];
  }

  void _setupData() {
    _values = widget.values;
    _currentValue = widget.initialValue;
    if (_currentValue != null) {
      final index = _values.indexOf(_currentValue as T);
      _scrollController = FixedExtentScrollController(initialItem: index);
    }
    _currentValue ??= _values.firstOrNull;
  }

  void _onConfirm() {
    Navigator.pop(context, _currentValue);
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _setupData();
  }

  @override
  void didUpdateWidget(covariant AuthCountryModal<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue || oldWidget.values != widget.values) {
      _setupData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        automaticallyImplyLeading: false,
        title: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: FontFamily.comfortaa,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 24.0,
          ),
          child: Text(localizations.country.capitalize()),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(padding: kTabLabelPadding),
            onPressed: _onConfirm,
            child: Text(localizations.ok.toUpperCase()),
          ),
        ],
      ),
      body: CupertinoPicker.builder(
        itemExtent: kToolbarHeight,
        childCount: _values.length,
        scrollController: _scrollController,
        onSelectedItemChanged: _onSelectedItemChanged,
        itemBuilder: (context, index) {
          final item = _values[index];
          return Center(
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                fontSize: 18.0,
              ),
              child: Text(
                _defaultValueFormatted(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
