import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/NotesService.dart';
import 'dart:math';

// Use hero to display note

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

}

class _CalendarPageState extends State<CalendarPage>{

  final int _count = 0;

  List<Map<String, dynamic>>? monthSummary;

  final List<String> flowers = ['assets/very_sad.jpg', 'assets/sad.jpg', 'assets/neutral.jpg', 'assets/happy.jpg', 'assets/really_happy.jpg'];

  DateTime current_day = DateTime.now();

   @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final summary = await NotesService.instance.fetchWeekSummary();
    setState(() {
      monthSummary = summary; // Update state to trigger rebuild
    });
  }

  void selectedDay(DateTime day, DateTime focus)
  {
    setState(()
    {
      current_day = day;
      //selected_events = getEventsForDay(day);
    });
  }

  //List<Event> getEventsForDay(DateTime day) {
    //return events[day] ?? [];
  //}

  String getMoodIcon(DateTime day) {
     
    int number = Random().nextInt(5);
    return flowers[number];
    
  }


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
              SizedBox(height: 5),
              TableCalendar(
                headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                rowHeight:60, 
                focusedDay: current_day, 
                firstDay: DateTime.utc(2025,2,30), 
                lastDay:DateTime.utc(2125,3,30),
                selectedDayPredicate: (day)=>isSameDay(day, current_day),
                onDaySelected: selectedDay,
                //eventLoader: (day) {return getEventsForDay(day);}),
                calendarBuilders: CalendarBuilders( 
                  defaultBuilder: (context, day, focusedDay) {
                    String moodIconPath = getMoodIcon(day);
                    return Center(
                      child: Column(
                        children: [
                          Text(day.day.toString()),
                          Image.asset(moodIconPath, height:40), 
                        ],
                        ),
                      );
                    }
                ), //icons of flowers
              ),
            ],
          ),
        ),
        PageTemplate.buildBottomSpacing(context)
      ]
    );
  }
}