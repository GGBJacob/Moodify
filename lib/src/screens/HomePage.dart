import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';

//TODO: Create page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>
{

  int _goodMoodCount = 0, _midMoodCount = 0, _badMoodCount = 0;
  int _count = 0;

  // Page building method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,  //spaces all children evenly in vertical axis

            children: [
              _firstBlock(),
              _secondBlock(),
              _thirdBlock(),
              _fourthBlock()
            ],
          )
      ),
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

  Widget _secondBlock()
  {
    return CustomBlock(
        child: Column(
            children: [
              Text(style: TextStyle(fontSize: 30),'Moods:'),
              _facesRow(),
            ]
        )
    );
  }

  Widget _thirdBlock()
  {
    return CustomBlock(
        child: Column(
            children: [
              Text(style: TextStyle(fontSize: 30),'Emotions:'),
              Text(style: TextStyle(fontSize: 20),'Happy, exited, tired'),
            ]
        )
    );
  }

  Widget _fourthBlock()
  {
    return CustomBlock(
        child: Column(
            children: [
              Text(style: TextStyle(fontSize: 30),'Activities:'),
              _activitiesRow(),
            ]
        )
    );
  }

  Widget _facesRow()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$_goodMoodCount x'),
        IconButton(onPressed: (){setState((){_goodMoodCount++;});}, icon: Icon(Icons.sentiment_very_satisfied, size: 50.0, color: Colors.green)),
        Text('$_midMoodCount x'),
        IconButton(onPressed: (){setState((){_midMoodCount++;});}, icon: Icon(Icons.sentiment_neutral_rounded, size: 50.0, color: Colors.orange)),
        Text('$_badMoodCount x'),
        IconButton(onPressed: (){setState((){_badMoodCount++;});}, icon: Icon(Icons.sentiment_very_dissatisfied, size: 50.0, color: Colors.red))
      ],
    );
  }

  Widget _activitiesRow()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.run_circle_outlined, size:50),
        Icon(Icons.local_drink_outlined, size:50),
        Icon(Icons.menu_book_rounded, size:50),
        Icon(Icons.sports_gymnastics_rounded, size:50),
        Icon(Icons.bed_rounded, size:50),
        ],
    );
  }
}
