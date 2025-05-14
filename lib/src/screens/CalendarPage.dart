import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:moodify/src/services/UserService.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/DatabaseService.dart';
import 'NoteDetailsPage.dart';
import '../utils/DateManipulations.dart';
import 'package:moodify/src/themes/colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<int, int>? monthSummary, dailyAverageMood;

  final List<String> flowers = [
    'assets/very_sad.png',
    'assets/sad.png',
    'assets/neutral.png',
    'assets/happy.png',
    'assets/very_happy.png'
  ];

  Map<DateTime, List<Map<String, dynamic>>> notes = {};

  DateTime selected_day = DateTime.now(); //day clicked by user
  DateTime focused_day =
      DateTime.now(); //determines which month is being displayed
  List<Map<String, dynamic>> selected_notes = [];
  String? userKey = null;

  @override
  void initState() {
    _loadData();
    super.initState();
    DatabaseService.instance.updates.listen((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  Widget getMoodIconWidget(int? mood) {
    if (mood == null || mood == -1) {
      return SizedBox(height: 40);
    } else {
      return Padding(
          padding: EdgeInsets.all(5),
          child: Image.asset(flowers[mood], height: 30));
    }
  }

  Future<void> _loadData() async {
    userKey = await UserService().getUserKey();
    final summary =
        await DatabaseService.instance.fetchAndCountMonthMoods(focused_day);
    DateTime first_day = DateTime(focused_day.year, focused_day.month, 1);
    DateTime last_day = DateTime(focused_day.year, focused_day.month + 1,
        0); //"zero" day is last day of moth
    final notes_for_month =
        await DatabaseService.instance.fetchNotes(first_day, last_day);

    setState(() {
      dailyAverageMood = summary;
      notes = DatabaseService.instance.groupNotesByDate(notes_for_month);
      //selected_notes = [];
      selected_notes = getNotesForDay(focused_day);
      selected_notes.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));
    });
  }

  void selectedDay(DateTime day, DateTime focus) {
    setState(() {
      selected_day = day;
      focused_day = focus;
      selected_notes = getNotesForDay(selected_day);
      selected_notes.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));
    });
  }

  List<Map<String, dynamic>> getNotesForDay(DateTime day) {
    final list = notes[day];
    if (list == null) return [];

    list.sort((a, b) => DateTime.parse(a['created_at'])
        .compareTo(DateTime.parse(b['created_at'])));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      CustomBlock(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: TableCalendar(
                key: ValueKey(focused_day.month),
                headerStyle: HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                rowHeight: 64,
                daysOfWeekHeight: 45,
                focusedDay: focused_day,
                firstDay: DateTime.utc(2020, 2, 30),
                lastDay: DateTime.utc(2125, 3, 30),
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) => isSameDay(day, selected_day),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2), //image always in the same place
                          child: getMoodIconWidget(dailyAverageMood?[day.day]),
                        ),
                      ],
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    //for days from another months
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
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? selectedLight
                                    : selectedDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? selectedBorderLight
                                        : todayBorderDark,
                                    width: 2),
                              ),
                              child: Center(
                                  child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? textLight
                                      : textDark,
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
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? todayLight
                                    : todayDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? todayBorderLight
                                        : selectedBorderDark,
                                    width: 2),
                              ),
                              child: Center(
                                  child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? textLight
                                      : textDark,
                                ),
                              ))),
                          getMoodIconWidget(dailyAverageMood?[day.day]),
                        ],
                      ),
                    );
                  },
                ), //icons of flowers
              ),
            ),
            selected_notes.isEmpty
                ? Text("")
                : Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Notes from ${noteDate(selected_day)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17))),
            SizedBox(height: 4),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(8),
                thickness: 6,
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: 10.0),
                  itemCount: selected_notes.length,
                  itemBuilder: (context, index) {
                    var note = selected_notes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteDetailsPage(
                                  note: note,
                                  date: noteDate(selected_day),
                                  image: Image.asset(flowers[note['mood']]),
                                  userKey: userKey!)),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Note created at: ${note['time']}'),
                          leading: Icon(Icons.sticky_note_2_outlined),
                          trailing: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: getMoodIconWidget(note['mood']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      PageTemplate.buildBottomSpacing(context)
    ]);
  }
}
