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

  ///Creates an `Elevated button` wrapped with `Padding` and `Expanded` widgets. 
  ///
  /// - [onPressed] - function called when the button is pressed, defaults to null.
  /// - [text] - button title, defaults to "Click me".
  /// - [backgroundColor] - button's main color, defaults to null.
  /// - [tintColor] - button's tint, defaults to null.
  /// 
  Widget _expandedButtonTile({
    VoidCallback? onPressed,
    String text = "Click me",
    Color? backgroundColor,
    Color? tintColor})
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row (
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                surfaceTintColor: tintColor,
                backgroundColor: backgroundColor,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                )
              ), 
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          )
        ],
      )
    );
  }

  /// Creates a button routing the user to the PHQ-9 test page
  Widget _testButton(context) {
    return _expandedButtonTile(
      onPressed: () 
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestPage()),
        );
      },
      text: "PHQ-9 test"
    );
  }

  Widget _predictionButton(context) {
    return _expandedButtonTile(
      onPressed: () 
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestPage()),
        );
      },
      text: "Crisis prediction"
    );
  }

  Widget _relaxationButton(context) {
    return _expandedButtonTile(
      onPressed: () 
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestPage()),
        );
      },
      text: "How to relax"
    );
  }


 Widget _blockWithTitleAndButtons(context) {
    return CustomBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PageTemplate.buildPageTitle("First aid"), 
          const SizedBox(height: 10), // break between elements
          _testButton(context),
          const SizedBox(height: 10),
          _predictionButton(context),
          const SizedBox(height: 10),
          _relaxationButton(context)
        ],
      ),
    );
  }
}