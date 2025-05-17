import 'package:flutter/material.dart';
import 'package:moodify/src/themes/colors.dart';

final SwitchThemeData switchTheme = SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? textOnSurfaceColorDark
        : const Color(0xFFF5F4B3);
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? surfaceColorDark
        : const Color(0xFF9AC5F4);
  }),
  trackOutlineColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? surfaceColorDark
        : const Color(0xFF9AC5F4);
  }),
);
