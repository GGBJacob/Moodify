import 'package:flutter/material.dart';
import 'package:moodify/src/themes/colors.dart';
import 'package:moodify/src/themes/switchTheme.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: whitewhite,
    scaffoldBackgroundColor: backgroundColorLight,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
        primary: whitewhite,
        onPrimary: blackblack,
        surface: surfaceColorLight,
        onSurface: blackblack,
        secondary: secondaryColorLight,
        onSecondary: pinkish,
        tertiary: accentColorLight,
        onTertiary: pinkish),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: blackblack),
      titleMedium: TextStyle(color: blackblack),
      titleSmall: TextStyle(color: blackblack),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: pinkish, foregroundColor: secondaryColorLight)),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: pinkish,
          foregroundColor: secondaryColorLight,
          shadowColor: blackblack // kolor tekstu
          ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColorLight, foregroundColor: pinkish),
    switchTheme: switchTheme,
    iconTheme: IconThemeData(color: blackblack),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColorLight,
        selectedItemColor: pinkish,
        unselectedItemColor: Colors.grey),
    appBarTheme: AppBarTheme(
        backgroundColor: pinkish, foregroundColor: secondaryColorLight),
    chipTheme: ChipThemeData(
      backgroundColor: pinkish,
      labelStyle: TextStyle(color: secondaryColorLight),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: whitewhite,
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderSide: BorderSide(color: blackblack)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: blackblack),
        ),
        labelStyle: TextStyle(color: blackblack)),
    cardTheme: CardTheme(
      color: secondaryColorLight,
    ),
    datePickerTheme: DatePickerThemeData(
      todayBorder: BorderSide(color: pinkish),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        return pinkish;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? lighterPinkish
            : whitewhite;
      }),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: blackblack,              // kolor kursora
      selectionColor: accentColorLight,  // kolor zaznaczenia tekstu
      selectionHandleColor: pinkish,     // kolor "kółka"/znacznika
    )
    );
