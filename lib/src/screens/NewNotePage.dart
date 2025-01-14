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

  //Mood
  int? _selectedMood; 
  
  //Emotions
  final List<String> _emotions = ["Happy", "Sad", "Angry", "Excited", "Calm"];
  final List<String> _selectedEmotions = [];
  
  //Activities
  final List<String> _activities = ["Yoga", "Walk", "School", "Friends", "Job"];
  final List<String> _selectedActivities = [];

  //Note
  final TextEditingController _textController = TextEditingController();
  final String _textFormOutput = "";

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
                              '${_now.day} ${_months[_now.month-1]} ${_now.year}'),
                          SizedBox(height:20),

                          //Mood
                          Text(style: TextStyle(fontSize: 30),'Mood:'),
                          _moodsBlock(),
                          SizedBox(height:20),

                          //Emotions
                          Text(style: TextStyle(fontSize: 30),'Emotions:'),
                          _emotionsBlock(),
                          SizedBox(height:20),

                          //Activities
                          Text(style: TextStyle(fontSize: 30),'Activities:'),
                          _activitiesBlock(),
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
                                String _textFormOutput = _textController.text;

                                //Validation
                                if(_formGlobalKey.currentState!.validate() && _selectedMood!=null){
                                  _formGlobalKey.currentState!.save();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Added!")),
                                  );
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
      children: [
        GestureDetector(
          onTap: (){
            setState(() {
              _selectedMood = 0;
            });
          },
          child: Icon(
            Icons.sentiment_very_satisfied_rounded,
            size: 50,
            color: _selectedMood == 0 ? Colors.green : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _selectedMood = 1;
            });
          },
          child: Icon(
            Icons.sentiment_satisfied_rounded,
            size: 50,
            color: _selectedMood == 1 ? Color(0xFF91AE00) : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _selectedMood = 2;
            });
          },
          child: Icon(
            Icons.sentiment_neutral_rounded,
            size: 50,
            color: _selectedMood == 2 ? Colors.orange : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _selectedMood = 3;
            });
          },
          child: Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 50,
            color: _selectedMood == 3 ? Colors.red  : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _selectedMood = 4;
            });
          },
          child: Icon(
            Icons.sentiment_very_dissatisfied_rounded,
            size: 50,
            color: _selectedMood == 4 ? Color(0xFF840303) : Colors.grey,
          ),
        )
      ],
    );
  }

  Widget _emotionsBlock() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 5.0,
              children: _selectedEmotions
                  .map((emotion) => Chip(
                label: Text(emotion),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ))
                  .toList(),
            ),
          ),
          IconButton(
            onPressed: () {
              _openDialogEmotions();
            },
            icon: Icon(
              Icons.add_circle_outline_rounded,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }


  Widget _activitiesBlock() {
    return Center(
        child: Row(
          children: [
        Expanded(
        child: Wrap(
        spacing: 8.0,
          runSpacing: 5.0,
                children: _selectedActivities
                    .map((activity) => Chip(
                  label: Text(activity),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ))
                    .toList(),
              ),
        ),
              IconButton(
                  onPressed: (){ _openDialogActivities();},
                  icon: Icon(Icons.add_circle_outline_rounded, size: 50,)
              )
            ]
        )
    );
  }

  Future<void> _openDialogEmotions() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text("Emotions"),
          content: Wrap(
            spacing: 8.0,
            children: _emotions.map((emotion) {
              final isSelected = _selectedEmotions.contains(emotion);
              return GestureDetector(
                onTap: () {
                  // Zmieniamy stan dialogu
                  setDialogState(() {
                    if (isSelected) {
                      _selectedEmotions.remove(emotion);
                    } else {
                      _selectedEmotions.add(emotion);
                    }
                  });

                  // Synchronizujemy z głównym widokiem
                  setState(() {});
                },
                child: Chip(
                  label: Text(emotion),
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

  Future<void> _openDialogActivities() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text("Activities"),
          content: Wrap(
            spacing: 8.0,
            children: _activities.map((activity) {
              final isSelected = _selectedActivities.contains(activity);
              return GestureDetector(
                onTap: () {
                  // Zmieniamy stan dialogu
                  setDialogState(() {
                    if (isSelected) {
                      _selectedActivities.remove(activity);
                    } else {
                      _selectedActivities.add(activity);
                    }
                  });

                  // Synchronizujemy z głównym widokiem
                  setState(() {});
                },
                child: Chip(
                  label: Text(activity),
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