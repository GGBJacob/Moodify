import 'package:flutter/material.dart';
import 'package:moodify/src/utils/themes/lightTheme.dart';

//colors
const Color backgroundColorDark = Color(0xFF1C3031);
const Color mainColorDark = Color(0xFF354B4D);
const Color textColorDark = Color(0xFFF0F0F0);
const Color accentColorDark = Color(0xFF4B707F);
const Color textOnAccentColorDark = Color(0xFFDCE4EC);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: mainColorDark,
  scaffoldBackgroundColor: backgroundColorDark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
      primary: mainColorDark,
      onPrimary: textColorDark,
      surface: accentColorDark,
      onSurface: textOnAccentColorDark),
  textTheme: TextTheme(
    titleLarge: TextStyle(color: textColorDark),
    titleMedium: TextStyle(color: textColorDark),
    titleSmall: TextStyle(color: textColorDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: accentColorDark,
          foregroundColor: textOnAccentColorDark)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: accentColorDark,
      foregroundColor: textOnAccentColorDark, // kolor tekstu
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColorDark, foregroundColor: textOnAccentColorDark),
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
  iconTheme: IconThemeData(color: textColorDark),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentColorDark,
      selectedItemColor: textOnAccentColorDark,
      unselectedItemColor: mainColorDark),
  appBarTheme: AppBarTheme(
      backgroundColor: accentColorDark, foregroundColor: textOnAccentColorDark),
  chipTheme: ChipThemeData(
      backgroundColor: mainColorDark,
      labelStyle: TextStyle(color: textColorDark)),
  dialogTheme: DialogTheme(
    backgroundColor: mainColorDark,
  ),
  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderSide: BorderSide(color: textColorDark)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColorDark),
      ),
      labelStyle: TextStyle(color: textColorDark)),
);
