import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';


class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();

}

class _NewNotePageState extends State<NewNotePage>
{final
  //Time 
  DateTime _now = DateTime.now();
  final List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  //Moods
  int? _selectedMood;
  
  final List<List<dynamic>> moodPairs = [
    [Icons.sentiment_very_dissatisfied_rounded, Color(0xFF840303)],
    [Icons.sentiment_dissatisfied_rounded, Colors.red],
    [Icons.sentiment_neutral_rounded, Colors.orange],
    [Icons.sentiment_satisfied_rounded, Color(0xFF91AE00)],
    [Icons.sentiment_very_satisfied_rounded, Colors.green],
  ];
  
  //Emotions
  final List<String> _emotions = ["Happy", "Sad", "Angry", "Excited", "Calm"];
  final List<String> _selectedEmotions = [];
  
  //Activities
  final List<String> _activities = ["Yoga", "Walk", "School", "Friends", "Job"];
  final List<String> _selectedActivities = [];

  //Note
  final TextEditingController _textController = TextEditingController();
  String _textFormOutput = "";

  //GlobalKey
  final GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child:  Column(
            children: [
          SizedBox(height:20),
              CustomBlock(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Form(
                      key: _formGlobalKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Date
                          Text(style: TextStyle(fontSize: 45),
                              '${_months[_now.month-1]} ${_now.day},  ${_now.year}'),
                          SizedBox(height:20),

                          //Mood
                          Text(style: TextStyle(fontSize: 30),'Mood:'),
                          _moodsBlock(),
                          SizedBox(height:20),

                          //Emotions
                          Text(style: TextStyle(fontSize: 30),'Emotions:'),
                          _interactiveList(_selectedEmotions, () => _openInteractiveDialog("Emotions", _emotions, _selectedEmotions)), // Passing interactive dialog as reference
                          SizedBox(height:20),

                          //Activities
                          Text(style: TextStyle(fontSize: 30),'Activities:'),
                          _interactiveList(_selectedActivities, () => _openInteractiveDialog("Activities", _activities, _selectedActivities)), // Passing interactive dialog as reference
                          SizedBox(height:20),

                          //Note
                          Text(style: TextStyle(fontSize: 30),'Note:'),
                          TextFormField(
                            decoration: InputDecoration(labelText: "How was your day?",
                              border: OutlineInputBorder()),
                            maxLength: 1000,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            controller: _textController,
                          ),
                          SizedBox(height:20),

                          //Save button
                          ElevatedButton(
                              onPressed: (){
                                //Note output
                                _textFormOutput = _textController.text;

                                //Validation
                                if(_formGlobalKey.currentState!.validate() && _selectedMood!=null){
                                  _formGlobalKey.currentState!.save();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Added!"), behavior: SnackBarBehavior.floating), // "floating" prevents moving of the "addNote" button
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)
                                )
                              ),
                              child: Text("Save")
                          )
                        ],
                      ),
                    )
                  ],
                )
            ),
              SizedBox(height:20)]
      ),
      )
      )
    );
  }

  Widget _moodsBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(moodPairs.length, (index)
      {
        return GestureDetector(
            onTap: (){
              setState(() {
                _selectedMood = index;
              });
            },
            child: Icon(
              moodPairs[index][0],
              size: 50,
              color: _selectedMood == index ? moodPairs[index][1] : Colors.grey,
            )
        );
      }
      ),
    );
  }


  Widget _interactiveList(List<String> listElements, VoidCallback onTapFunction)
  {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( 
            child: Wrap(
              spacing: 8.0,
              runSpacing: 5.0,
              children: [
                ...listElements.map(
                  (emotion) => Chip(
                    label: Text(emotion),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: onTapFunction,
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 50,
                    color: Colors.black,
                  ),
                )]
              )
              )
      ])
    );
  }

  Future<void> _openInteractiveDialog(String title, List<String> elements, List<String> selectedElements) => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(title),
          content: Wrap(
            spacing: 8.0,
            children: elements.map((element) {
              final isSelected = selectedElements.contains(element);
              return GestureDetector(
                onTap: () {
                  // Zmieniamy stan dialogu
                  setDialogState(() {
                    if (isSelected) {
                      selectedElements.remove(element);
                    } else {
                      selectedElements.add(element);
                    }
                  });

                  // Synchronizujemy z głównym widokiem
                  setState(() {});
                },
                child: Chip(
                  label: Text(element),
                  backgroundColor:
                  isSelected ? Colors.blue : Colors.grey[300],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie dialogu
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    ),
  );


}