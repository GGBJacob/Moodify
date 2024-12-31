import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      body: Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,  //spaces all children evenly in vertical axis
            children: [
              _topText(),
              _middleImage(),
              _facesRow(),
            ],
          )
      ),
    );
  }

  Widget _topText()
  {
    return Text(style: TextStyle(fontSize: 45),'Your week: $_count%');
  }

  Widget _middleImage()
  {
    return FlutterLogo(size: 150);
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

  List<BottomNavigationBarItem> _navbarItems()
  {
    return const [
      BottomNavigationBarItem(
          icon: Icon(Icons.mood),
          label: ''
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: ''
      ),
      BottomNavigationBarItem(
          icon: Icon(null),
          label: ''
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.question_mark),
          label: ''
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_rounded),
          label: ''
      ),
    ];
  }

}
