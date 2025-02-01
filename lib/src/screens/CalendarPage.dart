import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';

// Use hero to display note

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

}

class _CalendarPageState extends State<CalendarPage>
{
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      children: 
      [
        CustomBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(style: TextStyle(fontSize: 45), 'Calendar'),
              SizedBox(height: 20),
            ],
          ),
        ),
        PageTemplate.buildBottomSpacing(context)
      ]
    );
  }
}