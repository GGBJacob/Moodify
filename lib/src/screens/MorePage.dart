import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:moodify/src/screens/TestPage.dart';
import 'package:url_launcher/url_launcher.dart';

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
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
  Widget _expandedButtonTile({
    VoidCallback? onPressed,
    String text = "Click me",
    Color? backgroundColor,
    Color? tintColor})
  {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
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
                        )),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )))
          ],
        ));
  }

  /// Creates a button routing the user to the PHQ-9 test page
  Widget _testButton(context) {
    return _expandedButtonTile(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TestPage()),
          );
        },
        text: "PHQ-9 test");
  }

  Widget _relaxationButton(context) {
     return _expandedButtonTile(
    onPressed: () async {
      const url = 'https://pacjent.gov.pl/aktualnosc/jak-radzic-sobie-ze-stresem';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the webpage'),
            behavior: SnackBarBehavior.floating),
        );
      }
    },
    text: "How to deal with stress",
  );
  }
  
  Widget _emergencyNumbersButton() {
    return _expandedButtonTile(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _emergencyNumbersPopup(context),
        );
      },
      text: "Emergency Numbers List",
    );
  }

  Widget _emergencyNumbersPopup(BuildContext context) {
    // List of emergency numbers with country details
    final emergencyNumbers = [
      {'country': 'Poland 🇵🇱', 'number': '116 123'},
      {'country': 'European Union 🇪🇺', 'number': '112'},
      {'country': 'Canada 🇨🇦', 'number': '988'},
      {'country': 'United States 🇺🇸', 'number': '988'},
    ];

    return AlertDialog(
      title: Text('Emergency Numbers'),
      content:SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: emergencyNumbers.length,
          itemBuilder: (context, index) {
            final entry = emergencyNumbers[index];
            return ListTile(
              leading: Icon(Icons.phone, color: Colors.red),
              title: Text(entry['country']!),
              subtitle: Text('Tel: ${entry['number']}'),
              onTap: () async {
                String url = 'tel:${entry['number']}';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                    Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not dial ${entry['number']}'),
                      behavior: SnackBarBehavior.floating),
                  );
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

 Widget _blockWithTitleAndButtons(context) {
    return CustomBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          PageTemplate.buildPageTitle("First aid"), 
          _testButton(context),
          _relaxationButton(context),
          _emergencyNumbersButton(),
        ],
      ),
    );
  }
}
