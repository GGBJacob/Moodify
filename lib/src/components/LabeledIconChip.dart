import 'package:flutter/material.dart';

class LabeledIconChip extends StatelessWidget {
  final String label;
  final String? iconCodePoint;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const LabeledIconChip({
    super.key,
    required this.label,
    this.iconCodePoint,
    this.backgroundColor = const Color(0xFF8C4A60),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {

    int? parsedCodePoint = int.tryParse(iconCodePoint ?? '', radix: 16);

    final IconData iconData = parsedCodePoint != null
        ? IconData(parsedCodePoint, fontFamily: 'MaterialIcons')
        : Icons.help_outline;

    return Chip(
      backgroundColor: backgroundColor,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(iconData, size: 20, color: iconColor),
          Text(label, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
