import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import '../services/TestService.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final List<String> questions = [
    "1. Little interest or pleasure in doing things",
    "2. Feeling down, depressed, or hopeless",
    "3. Trouble falling or staying asleep, or sleeping too much",
    "4. Feeling tired or having little energy",
    "5. Poor appetite or overeating",
    "6. Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
    "7. Trouble concentrating on things, such as reading the newspaper or watching television",
    "8. Moving or speaking so slowly that other people could have noticed. Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
    "9. Thoughts that you would be better off dead, or of hurting yourself in some way"
  ];

  final List<String> options = [
    "Not at all",
    "Several days",
    "More than half the days",
    "Nearly every day"
  ];

  final List<String> results = [
    "no",
    "minimal",
    "mild",
    "moderate",
    "moderately severe",
    "severe"
  ];

  final List<int> cutpoints = [0,5,10,15,20,27]; //cutpoints of score value

  final String mainQuestion = "Over the last 2 weeks, how often have you been bothered by any of the following problems?";

  List<int> selectedAnswers = List.filled(9, -1);

  int calculateScore() {
    int score = 0;
    for (int answer in selectedAnswers) {
      if (answer != -1) score += answer;
    }
    return score;
  }

  void validateTest(BuildContext mainContext) {
    if (selectedAnswers.contains(-1)) {
      // If any answer is -1, show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Incomplete Test'),
            content: const Text(
                'Please answer all the questions before submitting.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      int points = calculateScore();
      String depressionIntensity = returnDepressionIntensity(points);
      TestService.instance.saveTest(points, selectedAnswers);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Test completed'),
            content: Text(
                'Your result is $points points, what may be sign of ${depressionIntensity} depression.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(mainContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String returnDepressionIntensity(int score)
  {
    String result = '';

    for (int i = 0; i < cutpoints.length; i++)
    {
        if (score<=cutpoints[i])
        {
          result = results[i];
          break;
        }
    }
    return result;
  }

  Widget _questionWidget(int index) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0), // Dodanie odstępu między blokami
    child: Center(
      child: CustomBlock(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questions[index],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Odstęp między pytaniem a opcjami
            ...options.asMap().entries.map((entry) {
              int optionIndex = entry.key;
              String option = entry.value;
              return RadioListTile<int>(
                title: Text(option),
                value: optionIndex,
                groupValue: selectedAnswers[index],
                onChanged: (int? value) {
                  setState(() {
                    selectedAnswers[index] = value!;
                  });
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('PHQ-9 Test'),
        backgroundColor: const Color.fromARGB(255, 163, 215, 149),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MainQuestionText(mainQuestion),
            ...List.generate(questions.length, (index) {
              return _questionWidget(index);
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                validateTest(context);
              },
              child: const Text('Submit Test'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _MainQuestionText(String mainQuestion)
{
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Dodanie odstępu między blokami
      child:
        CustomBlock(
          child: Text(
            mainQuestion,
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.black, 
            ),
          )
        )
    );
  }