import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:moodify/src/screens/TestPage.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      children: 
      [
        _blockWithTitleAndButtons(context),
        PageTemplate.buildBottomSpacing(context)
      ]
    );
  }

    Widget _titleText() {
    return Text(
      //padding: const EdgeInsets.only(top: 25.0, bottom: 25.0), //TODO make more responsive
  
        "More Page", // Page title TODO
        style: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: Colors.black, 
        ),
      )
    ;
  }

  Widget _testButton(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row (
        children: [ //TODO: Make a widget taking children and expanding them in a list
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent, 
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "PHQ-9 test",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              )
            )
        ]
      )
    );
  }


 Widget _blockWithTitleAndButtons(context) {
    return CustomBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _titleText(), 
          const SizedBox(height: 10), // break between elements
          _testButton(context),
        ],
      ),
    );
  }
}