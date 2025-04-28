import 'package:flutter/material.dart';
import 'package:moodify/src/utils/themes/lightTheme.dart';

//colors
const Color backgroundColorDark = Color(0xFF1C3031);
const Color mainColorDark = Color(0xFF354B4D);
const Color textColorDark = Color(0xFFF0F0F0);
const Color surfaceColorDark = Color(0xFF4B707F);
const Color textOnSurfaceColorDark = Color(0xFFDCE4EC);
const Color secondaryColorDark = Color(0xFF1C3031);
const Color textOnSecondaryColorDark = Color(0xFF8C4A60);
const Color accentColorDark = Color(0xFFDCE4EC);
const Color textOnAccentColorDark = Color(0xFF1C3031);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: mainColorDark,
  scaffoldBackgroundColor: backgroundColorDark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: mainColorDark,
    onPrimary: textColorDark,
    surface: surfaceColorDark,
    onSurface: textOnSurfaceColorDark,
    secondary: secondaryColorDark,
    onSecondary: textOnSecondaryColorDark,
    tertiary: accentColorDark,
    onTertiary: textOnAccentColorDark
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(color: textColorDark),
    titleMedium: TextStyle(color: textColorDark),
    titleSmall: TextStyle(color: textColorDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: textOnSecondaryColorDark,
      foregroundColor: secondaryColorDark
    )
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: textOnSecondaryColorDark,
      foregroundColor: secondaryColorDark // kolor tekstu
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: accentColorDark,
    foregroundColor: textOnAccentColorDark
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
  iconTheme: IconThemeData(color: textColorDark),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColorDark,
      selectedItemColor: textOnSurfaceColorDark,
      unselectedItemColor: mainColorDark),
  appBarTheme: AppBarTheme(
    backgroundColor: textOnSecondaryColorDark,
    foregroundColor: secondaryColorDark
  ),
  chipTheme: ChipThemeData(
      backgroundColor: textOnSecondaryColorDark,
      labelStyle: TextStyle(color: secondaryColorDark)),
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
    color: secondaryColorDark,
  ),
);
