import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import '../services/TrendAnalysis.dart';
import '../services/UserService.dart';
import '../utils/Pair.dart';

//TODO: Create page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _goodMoodCount = 0, _midMoodCount = 0, _badMoodCount = 0;
  final int _count = 0;

  // Page building method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
              child: Scrollbar(
            thumbVisibility: false,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _firstBlock(),
                    const SizedBox(height: 20),
                    _secondBlock(),
                    const SizedBox(height: 20),
                    _thirdBlock(),
                    const SizedBox(height: 20),
                    _fourthBlock(),
                    const SizedBox(height: 20),
                    _fifthBlock(),
                    PageTemplate.buildBottomSpacing(context)
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    ));
  }

  Widget _firstBlock() {
    return CustomBlock(
        child: Column(children: [
      Text(style: TextStyle(fontSize: 45), 'Your week: $_count%'),
      Icon(Icons.sentiment_satisfied, size: 150, color: Colors.cyan),
    ]));
  }

  Widget _secondBlock() {
    return CustomBlock(
        child: Column(children: [
      Text(style: TextStyle(fontSize: 30), 'Moods:'),
      _facesRow(),
    ]));
  }

  Widget _thirdBlock() {
    return CustomBlock(
        child: Column(children: [
      Text(style: TextStyle(fontSize: 30), 'Emotions:'),
      Text(style: TextStyle(fontSize: 20), 'Happy, excited, tired'),
    ]));
  }

  Widget _fourthBlock() {
    return CustomBlock(
        child: Column(children: [
      Text(style: TextStyle(fontSize: 30), 'Activities:'),
      _activitiesRow(),
    ]));
  }

  Widget _fifthBlock() {
    return FutureBuilder<List<Pair<String, double>>>(
      //UserService.instance.user_id!
      future: CrisisPredictionService.instance
          .dailyRisksPercents('c61f53e4-4783-4706-bbd1-891c876e414a'),
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
                        child: Text("Health Metric",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Risk Value [%]",
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child:
                              Text(risks[index].getSecond().toStringAsFixed(2)),
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

  Widget _facesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$_goodMoodCount x'),
        IconButton(
            onPressed: () {
              setState(() {
                _goodMoodCount++;
              });
            },
            icon: Icon(Icons.sentiment_very_satisfied,
                size: 50.0, color: Colors.green)),
        Text('$_midMoodCount x'),
        IconButton(
            onPressed: () {
              setState(() {
                _midMoodCount++;
              });
            },
            icon: Icon(Icons.sentiment_neutral_rounded,
                size: 50.0, color: Colors.orange)),
        Text('$_badMoodCount x'),
        IconButton(
            onPressed: () {
              setState(() {
                _badMoodCount++;
              });
            },
            icon: Icon(Icons.sentiment_very_dissatisfied,
                size: 50.0, color: Colors.red))
      ],
    );
  }

  Widget _activitiesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.run_circle_outlined, size: 50),
        Icon(Icons.local_drink_outlined, size: 50),
        Icon(Icons.menu_book_rounded, size: 50),
        Icon(Icons.sports_gymnastics_rounded, size: 50),
        Icon(Icons.bed_rounded, size: 50),
      ],
    );
  }
}
