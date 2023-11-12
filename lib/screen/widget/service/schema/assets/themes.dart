import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_assets.dart';

class AppThemes {
  static const primaryColor = CupertinoColors.systemBlue;
  static const tertialColor = Color(0xFFFF0000);
  static const _appBarTheme = AppBarTheme(
    centerTitle: false,
  );
  static const _floatingActionButtonTheme = FloatingActionButtonThemeData(
    shape: StadiumBorder(),
    elevation: 0.0,
  );
  static const _bottomSheetTheme = BottomSheetThemeData(
    clipBehavior: Clip.antiAlias,
    elevation: 2.0,
  );
  static const _dividerTheme = DividerThemeData(
    space: 0.8,
    thickness: 0.8,
  );
  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    ),
  );
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
    ),
  );
  static final _outlineButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
    ),
  );
  static const _inputDecorationTheme = InputDecorationTheme(
    isDense: true,
    labelStyle: TextStyle(fontSize: 18.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18.0)),
      borderSide: BorderSide(width: 2.0),
    ),
    contentPadding: EdgeInsets.all(12.0),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  );
  static const _listTileTheme = ListTileThemeData(
    horizontalTitleGap: 24.0,
    visualDensity: VisualDensity(
      horizontal: VisualDensity.minimumDensity,
      vertical: VisualDensity.minimumDensity,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        appBarTheme: _appBarTheme,
        dividerTheme: _dividerTheme,
        listTileTheme: _listTileTheme,
        fontFamily: FontFamily.futura,
        textButtonTheme: _textButtonTheme,
        bottomSheetTheme: _bottomSheetTheme,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlineButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        colorScheme: ColorScheme.fromSeed(
          // tertiaryContainer: const Color(0xFFF1EEE4),
          tertiaryContainer: const Color(0xFFF1E4E4),
          brightness: Brightness.light,
          // outline: Colors.black,
          seedColor: primaryColor,
          tertiary: tertialColor,
          primary: primaryColor,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        dividerTheme: _dividerTheme,
        listTileTheme: _listTileTheme,
        fontFamily: FontFamily.futura,
        textButtonTheme: _textButtonTheme,
        bottomSheetTheme: _bottomSheetTheme,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlineButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        appBarTheme: _appBarTheme.copyWith(backgroundColor: Colors.black),
        colorScheme: ColorScheme.fromSeed(
          tertiaryContainer: const Color(0xFF593F3F),
          brightness: Brightness.dark,
          background: Colors.black,
          onPrimary: Colors.white,
          seedColor: primaryColor,
          tertiary: tertialColor,
          primary: primaryColor,
        ),
      );
}
