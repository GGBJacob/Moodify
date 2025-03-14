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

  final int _count = 0;

  List<Map<String, dynamic>>? weekSummary;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final summary = await NotesService.instance.fetchWeekSummary();
    setState(() {
      weekSummary = summary; // Update state to trigger rebuild
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
              Text(style: TextStyle(fontSize: 45),'Your week: $_count%'),
              Icon(Icons.sentiment_satisfied, size:150, color: Colors.cyan),
            ]
        )
    );
  }

  Widget _moodsBlock()
  {
    Widget moodCounts = Text("Loading...");

    if (weekSummary != null && weekSummary!.isNotEmpty) {
      moodCounts = _moodsChart();
    }

    return CustomBlock(
        child: Column(
            children: [
              Text(style: TextStyle(fontSize: 30),'Moods:'),
              SizedBox(height: 20,),
              moodCounts
            ]
        )
    );
  }

  Widget _moodsChart()
  {
  final rowsCount = 10;

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

  var moods = weekSummary!.firstWhere(
    (item) => item['type'] == 'moods',
    orElse: () => {'data': []},
  );

  List<int> columns = [];
  List<int> moodCount = [0, 0, 0, 0, 0];
  int countSum = 0;
  for (var element in moods["data"])
  {
    countSum += element["count"] as int;
  }

  for (var element in moods["data"])
  {
    int idx = element["name"];
    columns.add(idx);
    moodCount[idx] = (rowsCount *element["count"]/countSum).round();
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (columnIndex) {
          int activeCount = columns.contains(columnIndex) ? moodCount[columnIndex] : 0;

          return Column(
              children: List.generate(rowsCount +1, (index) {
            
            if (index == rowsCount)
            {
              return Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(faces[columnIndex], color: activeColors[columnIndex])
                );
            }

            bool isActive = index >= (rowsCount - activeCount);

            return Padding(
              padding: EdgeInsets.only(bottom: index < rowsCount-1 ? 5.0 : 0),
              child: Container(
                  width: 50,
                  height: 10,
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

    if (weekSummary != null && weekSummary!.isNotEmpty) {
      final emotionsData = weekSummary!.firstWhere(
        (item) => item['type'] == 'emotions',
        orElse: () => {'data': []},
      )['data'] as List<Map<String, dynamic>>;
        fetchedEmotions = emotionsData.isNotEmpty
          ? Text(emotionsData.map((e) => e['name']).join(', '))
          : Row(
            children: [
              Icon(Icons.sentiment_very_dissatisfied),
              Text("No emotions, get to work!")
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

    if (weekSummary != null && weekSummary!.isNotEmpty) {
      final activitiesData = weekSummary!.firstWhere(
        (item) => item['type'] == 'activities',
        orElse: () => {'data': []},
      )['data'] as List<Map<String, dynamic>>;
        fetchedActivities = activitiesData.isNotEmpty
          ? Text(activitiesData.map((e) => e['name']).join(', '))
          : Row(
            children: [
              Icon(Icons.sentiment_very_dissatisfied),
              Text("No activities, get to work!")
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
