import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/NotesService.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

}

class _CalendarPageState extends State<CalendarPage>{

  Map<int, int>? monthSummary, dailyAverageMood;

  final List<String> flowers = ['assets/very_sad.jpg', 'assets/sad.jpg', 'assets/neutral.jpg', 'assets/happy.jpg', 'assets/really_happy.jpg'];

  Map<int, Image> moodImages = {};

  DateTime selected_day = DateTime.now();
  DateTime focused_day = DateTime.now();

  @override
  void initState() {
    _loadData();
    super.initState();
    NotesService.instance.updates.listen((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    for (int i = 0; i < flowers.length; i++) {
      moodImages[i] = Image.asset(flowers[i], height: 40);
      precacheImage(AssetImage(flowers[i]), context);
    }
  }

  Widget getMoodIconWidget(int? mood) {
  if (mood == null || mood == -1) {
    return SizedBox(height: 40); 
  } else {
    return moodImages[mood]!; 
  }
}

  Future<void> _loadData() async {
    final summary = await NotesService.instance.fetchAndCountMonthMoods(focused_day);

    setState(() {
      dailyAverageMood = summary;
    });
  }

  void selectedDay(DateTime day, DateTime focus)
  {
    setState(()
    {
      selected_day = day;
      focused_day = focus;
    });
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
              SizedBox(height: 10),
              TableCalendar(
                headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                rowHeight:64, 
                daysOfWeekHeight: 45,
                focusedDay: focused_day, 
                firstDay: DateTime.utc(2020,2,30), 
                lastDay:DateTime.utc(2125,3,30),
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day)=>isSameDay(day, selected_day),
                onDaySelected: selectedDay,
                onPageChanged: (newFocus) {  
                  setState(() {
                    focused_day = newFocus; 
                  });
                  _loadData(); 
                },
                calendarBuilders: CalendarBuilders( 
                  defaultBuilder: (context, day, focusedDay) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                                padding: const EdgeInsets.only(top: 2), //image always in the same place
                                child: getMoodIconWidget(dailyAverageMood?[day.day]),
                              ),
                        ],
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) { //for days from another months
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 40), 
                          ],
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) { 
                    return Center(
                        child: Column(
                          children: [
                             Container(
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 149, 49, 97).withAlpha(100), 
                                shape: BoxShape.circle, 
                                border: Border.all(color: const Color.fromARGB(255, 92, 21, 76), width: 2), 
                              ),
                              child: 
                              Center(
                                child: 
                              Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 79, 2, 54), 
                              ),
                            ))),
                            getMoodIconWidget(dailyAverageMood?[day.day]),
                          ],
                        ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) { 
                    return Center(
                        child: Column(
                          children: [
                             Container(
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 179, 103, 139).withAlpha(100), 
                                shape: BoxShape.circle, 
                                border: Border.all(color: const Color.fromARGB(255, 210, 154, 197), width: 2), 
                              ),
                              child: 
                              Center(
                                child: 
                              Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 79, 2, 54), 
                              ),
                            ))),
                            getMoodIconWidget(dailyAverageMood?[day.day]),
                          ],
                        ),
                    );
                  },
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