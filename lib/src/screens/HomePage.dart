
  import 'package:flutter/material.dart';
  import 'package:moodify/src/components/CustomBlock.dart';
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
      _loadData(true);
      streak = DatabaseService.instance.streakValue;
      DatabaseService.instance.updates.listen((_) {
        if(!mounted) return;
        setState(() {
          isSummaryLoading = true;
        });
        _loadData(false);
      });
      super.initState();
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
                thumbVisibility: false, 
                child: SingleChildScrollView( 
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
                        _fifthBlock(),
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
              Icon(Icons.local_fire_department_rounded,color: DatabaseService.instance.streakActive ? 
                Colors.orangeAccent
                : Colors.grey, size: 40,)
            ]);}
      return CustomBlock(
        child: Column(
          children: [
            streakText,
          ])  
          );
    }

    Widget _gradeBlock()
    {
      final List<String> flowers = ['assets/very_sad.png', 'assets/sad.png', 'assets/neutral.png', 'assets/happy.png', 'assets/very_happy.png'];
      double previousWeekAverageMood = previousWeekSummary.averageMood();
      double currentWeekAverageMood = weekSummary.averageMood();
      int moodTrend = previousWeekAverageMood!=0 ? (currentWeekAverageMood/previousWeekAverageMood*100).toInt() : 0;
      return CustomBlock(
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(flowers[(currentWeekAverageMood).round()], width: 170, height: 170),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Text(style: TextStyle(fontSize: 20), 'Mood trend: ${moodTrend}%'),
                    moodTrend > 0 ? 
                      Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.green) 
                        : moodTrend < 0 ? Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.red) : SizedBox.shrink(),
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
            ? Text(emotionsData.map((e) => e).join(', '))
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
            ? Text(activitiesData.map((e) => e).join(', '))
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

  Widget _fifthBlock() {
    return FutureBuilder<List<Pair<String, double>>>(
      //UserService.instance.user_id!
      future: CrisisPredictionService.instance.dailyRisksPercents('c61f53e4-4783-4706-bbd1-891c876e414a'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No data available"));
        } else {
    List<Pair<String, double>> risks = snapshot.data!;
    
          return CustomBlock(
            child: Table(
              children: [
                TableRow(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Health Metric", 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Risk Value [%]", 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
                // Data Rows
                ...List<TableRow>.generate(
                  risks.length - 1, // -1 to not display last row - health
                  (int index) => TableRow(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(risks[index].getFirst()),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(risks[index].getSecond().toStringAsFixed(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
    
  }
