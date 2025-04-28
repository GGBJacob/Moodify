import 'package:flutter/material.dart';
import 'package:moodify/src/utils/themes/darkTheme.dart';

//colors
const Color backgroundColorLight = Color(0xFFEEEEEE);
const Color mainColorLight = Color(0xFFFFFFFF);
const Color textColorLight = Color(0xFF000000);
const Color surfaceColorLight = Color(0xFFFAFAFA);
const Color textOnSurfaceColorLight = Color(0xFF8C4A60);
const Color secondaryColorLight = Color.fromARGB(255, 250, 240, 243);
const Color textOnSecondaryColorLight = Color(0xFF8C4A60);
const Color accentColorLight = Color(0xfffce4ec);
const Color textOnAccentColorLight = Color(0xFF8C4A60);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: mainColorLight,
  scaffoldBackgroundColor: backgroundColorLight,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: mainColorLight,
    onPrimary: textColorLight,
    surface: surfaceColorLight,
    onSurface: textColorLight,
    secondary: secondaryColorLight,
    onSecondary: textOnSecondaryColorLight,
    tertiary: accentColorLight,
    onTertiary: textOnAccentColorLight
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(color: textColorLight),
    titleMedium: TextStyle(color: textColorLight),
    titleSmall: TextStyle(color: textColorLight),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: textOnSecondaryColorLight,
      foregroundColor: secondaryColorLight
    )
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: textOnSecondaryColorLight,
      foregroundColor: secondaryColorLight, // kolor tekstu
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: accentColorLight,
    foregroundColor: textOnAccentColorLight
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? textOnSurfaceColorDark
          : const Color.fromARGB(255, 252, 255, 88);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? surfaceColorDark
          : const Color.fromARGB(255, 117, 215, 250);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? surfaceColorDark
          : const Color.fromARGB(255, 117, 215, 250);
    }),
  ),
  iconTheme: IconThemeData(color: textColorLight),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColorLight,
      selectedItemColor: textOnSurfaceColorLight,
      unselectedItemColor: Colors.grey),
  appBarTheme: AppBarTheme(
      backgroundColor: textOnSecondaryColorLight,
      foregroundColor: secondaryColorLight),
  chipTheme: ChipThemeData(
    backgroundColor: textOnSecondaryColorLight,
    labelStyle: TextStyle(color: secondaryColorLight),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: mainColorLight,
  ),
  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderSide: BorderSide(color: textColorLight)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColorLight),
      ),
      labelStyle: TextStyle(color: textColorLight)),
  cardTheme: CardTheme(
    color: secondaryColorLight,
  ),
);
