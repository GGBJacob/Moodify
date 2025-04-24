import 'package:flutter/material.dart';
import 'package:moodify/src/utils/themes/darkTheme.dart';

//colors
const Color backgroundColorLight = Color(0xFFBDD0D5);
const Color mainColorLight = Color(0xFFFFFFFF);
const Color textColorLight = Color(0xFF000000);
const Color accentColorLight = Color(0xFFCCDBEE);
const Color textOnAccentColorLight = Color(0xFF233C67);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: mainColorLight,
  scaffoldBackgroundColor: backgroundColorLight,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
      primary: mainColorLight,
      onPrimary: textColorLight,
      surface: accentColorLight,
      onSurface: textOnAccentColorLight),
  textTheme: TextTheme(
    titleLarge: TextStyle(color: textColorLight),
    titleMedium: TextStyle(color: textColorLight),
    titleSmall: TextStyle(color: textColorLight),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: accentColorLight,
          foregroundColor: textOnAccentColorLight)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: accentColorLight,
      foregroundColor: textOnAccentColorLight, // kolor tekstu
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColorLight,
      foregroundColor: textOnAccentColorLight),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? textOnAccentColorDark
          : textOnAccentColorLight;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? accentColorDark
          : accentColorLight;
    }),
  ),
  iconTheme: IconThemeData(color: textColorLight),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentColorLight,
      selectedItemColor: textOnAccentColorLight,
      unselectedItemColor: mainColorLight),
  appBarTheme: AppBarTheme(
      backgroundColor: accentColorLight,
      foregroundColor: textOnAccentColorLight),
  chipTheme: ChipThemeData(
      backgroundColor: mainColorLight,
      labelStyle: TextStyle(color: textColorLight)),
  dialogTheme: DialogTheme(
    backgroundColor: mainColorLight,
  ),
  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderSide: BorderSide(color: textColorLight)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColorLight),
      ),
      labelStyle: TextStyle(color: textColorLight)),
);
