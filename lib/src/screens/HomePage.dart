
  import 'dart:developer';

import 'package:flutter/material.dart';
  import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/LabeledIconChip.dart';
  import 'package:moodify/src/components/PageTemplate.dart';
  import 'package:moodify/src/models/NotesSummary.dart';
  import 'package:moodify/src/services/DatabaseService.dart';
  import '../services/TrendAnalysis.dart';
  import '../utils/Pair.dart';

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();

  }

  class _HomePageState extends State<HomePage>
  {
    NotesSummary weekSummary = NotesSummary();
    NotesSummary previousWeekSummary = NotesSummary();
    bool isSummaryLoading = true;
    int? streak;

    @override
    void initState() {
      checkConnection();
      _loadData(true);
      _loadRisks();
      DatabaseService.instance.updates.listen((_) {
        if(!mounted) return;
        setState(() {
          isSummaryLoading = true;
        });
        _loadData(false);
      });
      super.initState();
    }

    void checkConnection() async {
      if (!await DatabaseService.instance.testConnection()){
        _showNoInternetDialog();
      }
    }

    void _showNoInternetDialog()
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.wifi_off, color: Colors.red),
                SizedBox(width: 8),
                Text("No internet!"),
              ],
            ),
            content: const Text("Failed to establish a connection with the database. Make sure you are connected to the internet and restart the app."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _loadData(bool initialize) async {
      if (initialize)
      {
        streak = await DatabaseService.instance.loadStreak();
        previousWeekSummary = await DatabaseService.instance.fetchPreviousWeekSummary();
      }
      final summary = await DatabaseService.instance.fetchWeekSummary();
      if (!summary.isEmpty)
      {
        DatabaseService.instance.streakActive = summary.wasUserActiveToday();
      }
      await Future.delayed(const Duration(milliseconds: 500)); //Wait for a while so the loading is visible
      setState(() {
        weekSummary = summary; // Update state to trigger rebuild
        isSummaryLoading = false;
        streak = initialize ? streak : DatabaseService.instance.streakValue;
      });
    }

  final ScrollController _scrollController = ScrollController();
    // Page building method
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Expanded(
              child: Scrollbar(
                controller: _scrollController, 
                thumbVisibility: false, 
                child: SingleChildScrollView( 
                  controller: _scrollController,
                  child:
                    Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _streakBlock(),
                        const SizedBox(height: 20),
                        _gradeBlock(),
                        const SizedBox(height: 20),
                        _moodsBlock(),
                        const SizedBox(height: 20),
                        _emotionsBlock(),
                        const SizedBox(height: 20),
                        _activitiesBlock(),
                        const SizedBox(height: 20),
                        _risksBlock(),
                        PageTemplate.buildBottomSpacing(context)
                      ],
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
      )
    );
  }

    Widget _streakBlock()
    {
      Widget streakText;
      if (streak == null) {streakText = Text("Loading streak...");}
      else if (streak == -1) {streakText = Row(mainAxisAlignment: MainAxisAlignment.center, spacing:5, children:[Text("Error loading streak"), Icon(Icons.sentiment_very_dissatisfied_rounded, color: Colors.red, size: 20)]);}
      else {streakText = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
              Text(style: TextStyle(fontSize: 30), "Streak: $streak"),
              Icon(Icons.water_drop ,color: DatabaseService.instance.streakActive ? 
                const Color.fromARGB(255, 123, 172, 255)
                : Colors.grey, size: 40,)
            ]);}
      return CustomBlock(
        child: Column(
          children: [
            streakText,
          ])  
          );
    }

  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mood Flower & Trend'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children:[
                  Text('🌸 Mood Flower:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'The flower shows your average mood for the current week. '
                    'The happier it is, the better your overall mood! '
                    'It’s a simple, visual way to reflect how you’ve been feeling this week.',
                  )
                ]
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🌟 Mood Trend:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    'This shows how your mood this week compares to last week. '
                    'Make sure to log your moods to enable the trend visualisation.',
                  ),
                  SizedBox(height: 10),
                  Row(children: [
                    Padding(
                      padding: EdgeInsets.only(right:5),
                      child:Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.green)),
                    Expanded(
                      child: Text('An upward arrow means you are feeling better.'))
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    Padding(
                      padding: EdgeInsets.only(left: 2, right: 8),
                      child: Text('＝', style: TextStyle(fontSize: 20, color: Colors.orangeAccent, fontWeight: FontWeight.bold))),
                    Expanded(
                      child:Text("A flat line means your mood stayed about the same."))
                  ],),
                  SizedBox(height: 10),
                  Row(children: [
                    Padding(
                      padding: EdgeInsets.only(right:5),
                      child:Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.red)),
                    Expanded(
                      child:Text('A downward arrow means your mood has decreased.'))
                  ])
                ]
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

    Widget _gradeBlock()
    {
      final List<String> flowers = ['assets/very_sad.png', 'assets/sad.png', 'assets/neutral.png', 'assets/happy.png', 'assets/very_happy.png'];
      double? previousWeekAverageMood = previousWeekSummary.averageMood();
      double? currentWeekAverageMood = weekSummary.averageMood();
      bool showTrend = previousWeekAverageMood != null && currentWeekAverageMood != null;
      int moodTrend = showTrend ? (currentWeekAverageMood-previousWeekAverageMood/previousWeekAverageMood*100).toInt() : 0;
      return CustomBlock(
          child: Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    GestureDetector(
                      onTap: showHelpDialog,
                      child: Icon(Icons.help_outline),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom:10),
                  child: Image.asset(flowers[(currentWeekAverageMood ?? 2).round()], width: 170, height: 170),
                ),
                if (showTrend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      const Text(style: TextStyle(fontSize: 20), 'Mood trend:'),
                      moodTrend > 0 
                        ? const Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.green) 
                        : moodTrend < 0 
                          ? const Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.red) 
                          : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text('＝', style: TextStyle(fontSize: 20, color: Colors.orangeAccent, fontWeight: FontWeight.bold))),
                      ]
                    ),
              ]
          )
      );
    }

    Widget _moodsBlock()
    {
      Widget moodCounts = Text("Loading...");

      if (!isSummaryLoading) {
        weekSummary.isEmpty ? 
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                Icon(Icons.sentiment_very_dissatisfied_outlined),
                Text("No moods found!")
              ]
            ) :
          moodCounts = _moodsChart();
      }

      return CustomBlock(
          child: Column(
              children: [
                Text(style: TextStyle(fontSize: 30),'Moods:'),
                moodCounts
              ]
          )
      );
    }

  Widget _moodsChart()
  {
    
  final rowCount = 10;
  final columnCount = 5;

  final List<Color> activeColors = [
  Color(0xFF840303),
  Colors.red,
  Colors.orange,
  Color(0xFF91AE00),
  Colors.green,
  ];

  final List<Color> disabledColors = [
  Color(0xFFFFB3B3), 
  Color(0xFFFFC2C2), 
  Color(0xFFFFE0B2), 
  Color(0xFFE6EE9C), 
  Color(0xFFB9F6CA),
  ];

  final List<IconData> faces = [
    Icons.sentiment_very_dissatisfied_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_very_satisfied_rounded,
  ];

  // Making sure nobody forgets to change any of the mentioned variables
  assert (rowCount > 0);
  assert (columnCount > 0);
  assert (columnCount == activeColors.length);
  assert (activeColors.length == disabledColors.length);
  assert (disabledColors.length == faces.length);

  var moods = weekSummary.moods!;

  List<int> columns = [];
  List<int> moodCount = List.filled(columnCount, 0);
  int countSum = 0;
  for (var element in moods)
  {
    countSum += element.second;
    int idx = element.first;
    columns.add(idx);
    moodCount[idx] = rowCount * element.second;
  }


  return Padding(
    padding: EdgeInsets.only(left: 10, right: 10, top: 20),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(columnCount, (columnIndex) {
          int activeCount = columns.contains(columnIndex) ? (moodCount[columnIndex]/countSum).floor() : 0;

          return Column(
              children: List.generate(rowCount +1, (index) {
            
            if (index == rowCount)
            {
              return Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(faces[columnIndex], color: activeColors[columnIndex])
                );
            }

            bool isActive = index >= (rowCount - activeCount);

            return Padding(
              padding: EdgeInsets.only(bottom: index < rowCount-1 ? 2.0 : 0),
              child: Container(
                  width: 50,
                  height: 8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isActive
                          ? activeColors[columnIndex]
                          : disabledColors[columnIndex])),
            );
          }));
        })));
  }

    Widget _emotionsBlock()
    {
      Widget fetchedEmotions = Text("Loading...");

      if (!isSummaryLoading && !weekSummary.isEmpty) {
        final emotionsData = weekSummary.topEmotions(5);
          fetchedEmotions = emotionsData.isNotEmpty && !isSummaryLoading
            ? 
            Wrap(
              spacing: 8,
              children:
                emotionsData.map((e) {
                  return LabeledIconChip(label: e, iconCodePoint: weekSummary.icons![e]);
                }).toList(),
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                Icon(Icons.sentiment_very_dissatisfied_outlined),
                Text("No emotions found!")
              ]
            );
      }

      return CustomBlock(
          child: Column(
              children: [
                Text(style: TextStyle(fontSize: 30),'Emotions:'),
                fetchedEmotions
              ]
          )
      );
    }

    Widget _activitiesBlock()
    {
      Widget fetchedActivities = Text("Loading...");

      if (!isSummaryLoading && !weekSummary.isEmpty) {
        final activitiesData = weekSummary.topActivities(5);
          fetchedActivities = activitiesData.isNotEmpty
            ? Wrap(
              spacing: 8,
              children:
                activitiesData.map((e) {
                  return LabeledIconChip(label: e, iconCodePoint: weekSummary.icons![e]);
                }).toList(),
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                Icon(Icons.sentiment_very_dissatisfied_outlined),
                Text("No activities found!")
              ]
            );
      }

      return CustomBlock(
          child: Column(
              children: [
                Text(style: TextStyle(fontSize: 30),'Activities:'),
                fetchedActivities
              ]
          )
      );
    }

  bool _isLoading = true;
  List<Pair<String, double>>? _risks;
  void _loadRisks() async {
    setState(() => _isLoading = true);

    try {
      _risks = await CrisisPredictionService.instance.dailyRisksPercents();
    } catch (e) {
      log("Error loading risks: $e");
      _risks = [];
    }

    setState(() => _isLoading = false);
  }

 Widget _risksBlock() {
  final risks = _risks ?? [];

  final sortedRisks = List<Pair<String, double>>.from(risks)
    ..sort((a, b) => b.second.compareTo(a.second)); // sort descending
  final topRisks = sortedRisks.take(3).toList();

  return CustomBlock(
    child: Column(
      children:[
        Text(
          "Top Risk Metrics:",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
    _isLoading
        ? Center(child: Text("Loading risks..."))
        : risks.isEmpty
            ? Center(child: Text("No data available"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  SizedBox(height: 12),
                  ...topRisks.map((risk) {
                    Color getColor(double value) {
                      if (value < 20) return Colors.green;
                      if (value < 40) return Colors.yellow.shade600;
                      if (value < 60) return Colors.orangeAccent;
                      if (value < 80) return Colors.redAccent;
                      return Colors.red;
                    }
                    Color riskColor = getColor(risk.second);
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: riskColor.withValues(alpha: 0.8), 
                          width: 1.5,
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              riskColor.withValues(alpha: 1.0),
                              riskColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withValues(alpha: 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: riskColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.warning_rounded,
                                color: riskColor,
                                size: 26,
                              ),
                            ),
                          ),
                          title: Text(
                            risk.first,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            "${risk.second.toStringAsFixed(1)}%",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
  ]));
}

    
  }
