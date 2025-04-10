  import 'package:flutter/material.dart';
  import 'package:moodify/src/components/CustomBlock.dart';
  import 'package:moodify/src/components/PageTemplate.dart';
  import 'package:moodify/src/services/NotesService.dart';
  import '../services/TrendAnalysis.dart';
  import '../utils/Pair.dart';

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();

  }

  class _HomePageState extends State<HomePage>
  {
    List<Map<String, dynamic>>? weekSummary;
    bool isSummaryLoading = true;

    @override
    void initState() {
      _loadData();
      NotesService.instance.updates.listen((_) {
        setState(() {
          isSummaryLoading = true;
        });
        _loadData();
      });
      super.initState();
    }

    Future<void> _loadData() async {
      final summary = await NotesService.instance.fetchWeekSummary();
      await Future.delayed(const Duration(milliseconds: 500)); //Wait for a while so the loading is visible
      setState(() {
        weekSummary = summary; // Update state to trigger rebuild
        isSummaryLoading = false;
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
                        _firstBlock(),
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

    Widget _firstBlock()
    {
      return CustomBlock(
          child: Column(
              children: [
                Text(style: TextStyle(fontSize: 45),'Your week: 0 %'),
                Icon(Icons.sentiment_satisfied, size:150, color: Colors.cyan),
              ]
          )
      );
    }

    Widget _moodsBlock()
    {
      Widget moodCounts = Text("Loading...");

      if (!isSummaryLoading) {
        final moodsData = weekSummary!.firstWhere(
          (item) => item['type'] == 'moods',
          orElse: () => {'data': []}) ['data'] as List<Map<String, dynamic>>;
          moodCounts = moodsData.isEmpty ? 
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
  Color(0xFFD4E157), 
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

  var moods = weekSummary!.firstWhere(
    (item) => item['type'] == 'moods',
    orElse: () => {'data': []},
  );

  List<int> columns = [];
  List<int> moodCount = List.filled(columnCount, 0);
  int countSum = 0;
  for (var element in moods["data"])
  {
    countSum += element["count"] as int;
    int idx = element["name"];
    columns.add(idx);
    moodCount[idx] = rowCount * element["count"] as int;
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

      if (!isSummaryLoading && weekSummary != null && weekSummary!.isNotEmpty) {
        final emotionsData = weekSummary!.firstWhere(
          (item) => item['type'] == 'emotions',
          orElse: () => {'data': []},
        )['data'] as List<Map<String, dynamic>>;
          fetchedEmotions = emotionsData.isNotEmpty && !isSummaryLoading
            ? Text(emotionsData.map((e) => e['name']).join(', '))
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

      if (!isSummaryLoading && weekSummary != null && weekSummary!.isNotEmpty) {
        final activitiesData = weekSummary!.firstWhere(
          (item) => item['type'] == 'activities',
          orElse: () => {'data': []},
        )['data'] as List<Map<String, dynamic>>;
          fetchedActivities = activitiesData.isNotEmpty
            ? Text(activitiesData.map((e) => e['name']).join(', '))
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
