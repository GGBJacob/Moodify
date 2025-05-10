import 'package:flutter/material.dart';
import 'package:moodify/src/utils/themes/colors.dart';
import 'package:moodify/src/utils/themes/switchTheme.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: mainColorDark,
  scaffoldBackgroundColor: darkColor,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
      primary: mainColorDark,
      onPrimary: textColorDark,
      surface: surfaceColorDark,
      onSurface: textOnSurfaceColorDark,
      secondary: darkColor,
      onSecondary: blueish,
      tertiary: accentColorDark,
      onTertiary: darkColor),
  textTheme: TextTheme(
    titleLarge: TextStyle(color: textColorDark),
    titleMedium: TextStyle(color: textColorDark),
    titleSmall: TextStyle(color: textColorDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: blueish, foregroundColor: accentColorDark)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
        backgroundColor: blueish,
        foregroundColor: textOnSurfaceColorDark // kolor tekstu
        ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColorDark, foregroundColor: darkColor),
  switchTheme: switchTheme,
  iconTheme: IconThemeData(color: textColorDark),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColorDark,
      selectedItemColor: textOnSurfaceColorDark,
      unselectedItemColor: mainColorDark),
  appBarTheme:
      AppBarTheme(backgroundColor: blueish, foregroundColor: accentColorDark),
  chipTheme: ChipThemeData(
      backgroundColor: blueish,
      labelStyle: TextStyle(color: textOnSurfaceColorDark),
      side: BorderSide(
        color: blueish
      )
      ),
  dialogTheme: DialogTheme(
    backgroundColor: mainColorDark,
  ),
  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderSide: BorderSide(color: textColorDark)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColorDark),
      ),
      labelStyle: TextStyle(color: textColorDark)),
  cardTheme: CardTheme(
    color: darkColor,
  ),
);
