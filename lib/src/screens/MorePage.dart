import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/screens/TestPage.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // spaces all children evenly in vertical axis
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Expanded(
              child: _blockWithTitleAndButtons(context)),
            SizedBox(height: MediaQuery.of(context).size.height *0.03)
          ],
        ),
      ),
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
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TestPage()),
          );
        },
        child: const Text(
          "PHQ-9 test",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent, 
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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