import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '_widget.dart';

class AuthAppBar extends StatelessWidget {
  const AuthAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      leading: const Center(child: CustomBackButton()),
      title: Text(localizations.login.toUpperCase()),
    );
  }
}

class AuthEditPhoneAppBar extends StatelessWidget {
  const AuthEditPhoneAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar.medium(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      leading: const Center(child: CustomBackButton()),
      title: Text(localizations.changephonenumber.toUpperCase()),
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
    return SizedBox(
      width: 110.0,
      child: Visibility(
        visible: onPressed != null,
        replacement: const TextButton(
          onPressed: null,
          child: CustomProgressIndicator(),
        ),
        child: Visibility(
          visible: dialCode != null && countryCode != null,
          replacement: TextButton(
            onPressed: onPressed,
            child: const Icon(CupertinoIcons.refresh),
          ),
          child: Builder(
            builder: (context) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: theme.textTheme.titleLarge!.copyWith(
                    letterSpacing: 0.0,
                    fontSize: 18.0,
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                onPressed: onPressed,
                icon: Text("${CustomString.toFlag(countryCode ?? '--')} ${dialCode ?? '--'}"),
                label: const Icon(CupertinoIcons.chevron_down, size: 18.0),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthPhoneTextField extends StatelessWidget {
  const AuthPhoneTextField({
    super.key,
    required this.format,
    this.autofocus = false,
    required this.controller,
    required this.prefixIcon,
  });
  final String? format;
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
        inputFormatters: [MaskTextInputFormatter(mask: format)],
        style: const TextStyle(fontSize: 18.0, letterSpacing: 0.0),
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
      top: false,
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

class AuthCountryEmptyModal extends StatelessWidget {
  const AuthCountryEmptyModal({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: Text("format du numero de telephone".toUpperCase()),
      content: const Text("Pour continuer, renseignez votre pays et votre numero de telephone."),
      actions: const [
        SizedBox.shrink(),
        CustomModalConfirmAction(),
      ],
    );
  }
}

class AuthConfirmPhoneModal extends StatelessWidget {
  const AuthConfirmPhoneModal({
    super.key,
    required this.phone,
  });
  final String phone;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomModal(
      title: Text(phone.toUpperCase()),
      content: Text(localizations.rightnumber.capitalize()),
      actions: [
        CustomModalCancelAction(
          text: localizations.edit.toUpperCase(),
        ),
        CustomModalConfirmAction(
          text: localizations.yes.toUpperCase(),
        ),
      ],
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
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        title: Text(localizations.country.toUpperCase()),
        titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
          fontFamily: FontFamily.avenirNext,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(padding: kTabLabelPadding),
            onPressed: _onConfirm,
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                fontFamily: FontFamily.avenirNext,
              ),
              child: Text(localizations.ok.toUpperCase()),
            ),
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
                letterSpacing: -0.4,
                fontSize: 18.0,
              ),
              child: Text(_defaultValueFormatted(item)),
            ),
          );
        },
      ),
    );
  }
}
