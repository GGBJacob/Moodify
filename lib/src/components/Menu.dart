import 'package:flutter/material.dart';
import 'package:moodify/src/screens/HomePage.dart';
import 'package:moodify/src/screens/CalendarPage.dart';
import 'package:moodify/src/screens/MorePage.dart';
import 'package:moodify/src/screens/SettingsPage.dart';
import 'package:moodify/src/screens/NewNotePage.dart';

//TODO: Change invisible button solution. Padding?

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu>{

  int _currentPageIndex = 0;

  // Page list
  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    Center(child: Text('EMPTY')), //temporary solution
    MorePage(),
    SettingsPage(),
  ];

  // Menu bar with icons
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
      BottomNavigationBarItem( //temporary solution
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display current page
      body: _pages[_currentPageIndex],
      //Plus button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new note
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewNotePage()),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      // Menu bar
      bottomNavigationBar: BottomNavigationBar(
        items: _navbarItems(),
        currentIndex: _currentPageIndex,
        onTap: (index) {
          setState(() {
            if(index != 2) {
              _currentPageIndex = index;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}