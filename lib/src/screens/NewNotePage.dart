import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import '../services/NotesService.dart';
import '../utils/DateManipulations.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();

}

class _NewNotePageState extends State<NewNotePage>
{
  //Time 
  final DateTime _now = DateTime.now();

  //Moods
  int? _selectedMood;
  
  final List<List<dynamic>> moodPairs = [
    [Icons.sentiment_very_dissatisfied_rounded, Color(0xFF840303)],
    [Icons.sentiment_dissatisfied_rounded, Colors.red],
    [Icons.sentiment_neutral_rounded, Colors.orange],
    [Icons.sentiment_satisfied_rounded, Color(0xFF91AE00)],
    [Icons.sentiment_very_satisfied_rounded, Colors.green],
  ];
  
  //Emotions and Activities
  List<Map<String, dynamic>> _emotions = [];
  List<Map<String, dynamic>> _activities = [];
  final List<int> _selectedEmotions = [];
  final List<int> _selectedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Asynchronous data loading
  }

  Future<void> _loadData() async {
    try {
      final emotions = await NotesService.instance.fetchEmotions();
      final activities = await NotesService.instance.fetchActivities();
      setState(() {
        _emotions = emotions;
        _activities = activities;
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  //Note
  final TextEditingController _textController = TextEditingController();
  String _textFormOutput = "";

  //GlobalKey
  final GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('New note'), 
      ),
      body:
        SingleChildScrollView(
          child: Align(alignment: Alignment.topCenter,
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
                          Text(style: TextStyle(fontSize: 30),
                              '${monthToString(_now.month-1)} ${_now.day}${getDateEnding(_now.day)},  ${_now.year}'),
                          SizedBox(height:20),

                          //Mood
                          Text(style: TextStyle(fontSize: 20),'Mood:'),
                          _moodsBlock(),
                          SizedBox(height:20),

                          //Emotions
                          Text(style: TextStyle(fontSize: 20),'Emotions:'),
                          _interactiveList(_selectedEmotions ,_emotions, () => _openInteractiveDialog("Emotions", _emotions, _selectedEmotions)), // Passing interactive dialog as reference
                          SizedBox(height:20),

                          //Activities
                          Text(style: TextStyle(fontSize: 20),'Activities:'),
                          _interactiveList(_selectedActivities ,_activities, () => _openInteractiveDialog("Activities", _activities, _selectedActivities)), // Passing interactive dialog as reference
                          SizedBox(height:20),

                          //Note
                          Text(style: TextStyle(fontSize: 20),'Note:'),
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
                                  NotesService.instance.saveNote(_selectedMood!, _selectedEmotions, _selectedActivities, _textFormOutput);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Added!"), behavior: SnackBarBehavior.floating), // "floating" prevents moving of the "addNote" button
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
        ),
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


  Widget _interactiveList(List<int> selectedElements, List<Map<String, dynamic>> listElements, VoidCallback onTapFunction)
  {
    final filteredElements = listElements.where((element) => selectedElements.contains(element['id'])).toList();

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( 
            child: Wrap(
              spacing: 8.0,
              runSpacing: 5.0,
              children: [
                ...filteredElements.map(
                  (element) => Chip(
                    label: Text(element['name']),
                    backgroundColor: Color(0xFF8C4A60),
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

  Future<void> _openInteractiveDialog(String title, List<Map<String, dynamic>> elements, List<int> selectedElements) => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(title),
          content: Wrap(
            spacing: 8.0,
            children: elements.map((element) {
              final isSelected = selectedElements.contains(element['id']);
              return GestureDetector(
                onTap: () {
                  // Zmieniamy stan dialogu
                  setDialogState(() {
                    if (isSelected) {
                      selectedElements.remove(element['id']);
                    } else {
                      selectedElements.add(element['id']);
                    }
                  });

                  // Synchronizujemy z głównym widokiem
                  setState(() {});
                },
                child: Chip(
                  label: Text(element['name']),
                  backgroundColor:
                  isSelected ? Color(0xFF8C4A60) : Colors.grey[300],
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