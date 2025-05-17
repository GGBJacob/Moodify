import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import '../services/DatabaseService.dart';
import '../utils/DateManipulations.dart';
import 'package:moodify/src/themes/colors.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  //Time
  final DateTime _now = DateTime.now();

  //Moods
  int? _selectedMood;
  bool isSaving = false;
  bool displayMoodError = false;
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

  final ScrollController _activitiesScrollController = ScrollController();
  final ScrollController _emotionsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData(); // Asynchronous data loading
  }

  Future<void> _loadData() async {
    try {
      final emotions = await DatabaseService.instance.fetchEmotions();
      final activities = await DatabaseService.instance.fetchActivities();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: Text('New note'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child:SingleChildScrollView(
          child: Align(
        alignment: Alignment.topCenter,
        child: Column(children: [
          SizedBox(height: 20),
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
                    Text(
                        style: TextStyle(fontSize: 30),
                        '${monthToString(_now.month)} ${_now.day}${getDateEnding(_now.day)},  ${_now.year}'),
                    SizedBox(height: 20),

                    //Mood
                    Text(style: TextStyle(fontSize: 20), 'Mood:'),
                    _moodsBlock(),
                    Visibility(
                          visible: displayMoodError,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child:
                            Center(
                              child:Text(
                            "Please select a mood",
                            style: TextStyle(color: Colors.red),
                          ))),

                    //Emotions
                    Text(style: TextStyle(fontSize: 20), 'Emotions:'),
                    _interactiveList(
                        _selectedEmotions,
                        _emotions,
                        (){
                          FocusScope.of(context).requestFocus(FocusNode());
                          _openInteractiveDialog(
                            "Emotions",
                            _emotions,
                            _selectedEmotions,
                            _emotionsScrollController);}), // Passing interactive dialog as reference
                    SizedBox(height: 20),

                    //Activities
                    Text(style: TextStyle(fontSize: 20), 'Activities:'),
                    _interactiveList(
                        _selectedActivities,
                        _activities,
                        (){
                          FocusScope.of(context).requestFocus(FocusNode());
                          _openInteractiveDialog(
                            "Activities",
                            _activities,
                            _selectedActivities,
                            _activitiesScrollController);}), // Passing interactive dialog as reference
                    SizedBox(height: 20),

                    //Note
                    Text(style: TextStyle(fontSize: 20), 'Note:'),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "How was your day?",
                          border: OutlineInputBorder()),
                      maxLength: 1000,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      controller: _textController,
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    SizedBox(height: 20),

                    //Save button
                    ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () {
                                FocusScope.of(context).unfocus(); // Hide the keyboard if open
                                //Note output
                                _textFormOutput = _textController.text;

                                //Validation
                                if (_formGlobalKey.currentState!.validate() &&
                                    _selectedMood != null) {
                                  _handleSaveNote();
                                }
                                else{
                                  setState(() {
                                    displayMoodError = true;
                                  });
                                }
                              },
                        style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0))),
                        child: Text("Save"))
                  ],
                ),
              )
            ],
          )),
          SizedBox(height: 20)
        ]),
      )),
    ));
  }

  Future<void> _handleSaveNote() async {
    setState(() {
      isSaving = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: Row(
          children: [
            CircularProgressIndicator(color: whitewhite),
            SizedBox(width: 20),
            Text(
              "Saving...",
              style: TextStyle(color: whitewhite),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );

    _formGlobalKey.currentState!.save();

    int? res = await DatabaseService.instance.saveNote(_selectedMood!,
        _selectedEmotions, _selectedActivities, _textFormOutput);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (res != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 20),
            Text("Note added!", style: TextStyle(color: whitewhite)),
          ]),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Row(children: [
            Icon(Icons.close, color: Colors.white),
            SizedBox(width: 20),
            Text("Failed to add note!", style: TextStyle(color: whitewhite)),
          ]),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _moodsBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(moodPairs.length, (index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMood = index;
                displayMoodError = false;
              });
            },
            child: Icon(
              moodPairs[index][0],
              size: 50,
              color: _selectedMood == index ? moodPairs[index][1] : Colors.grey,
            ));
      }),
    );
  }

  Widget _interactiveList(List<int> selectedElements,
      List<Map<String, dynamic>> listElements, VoidCallback onTapFunction) {
    final filteredElements = listElements
        .where((element) => selectedElements.contains(element['id']))
        .toList();

    return Center(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Wrap(spacing: 8.0, runSpacing: 5.0, children: [
        ...filteredElements.map(
          (element) => Container(
            height: 32,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  element['icon']?.icon ?? Icons.help_outline,
                  size: 22,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                SizedBox(width: 6),
                Text(
                  element['name'],
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onTapFunction,
          child: Icon(
            Icons.add_circle_outline_rounded,
            size: 50,
          ),
        )
      ]))
    ]));
  }

  Future<void> _openInteractiveDialog(
          String title,
          List<Map<String, dynamic>> elements,
          List<int> selectedElements,
          ScrollController scrollController) =>
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
                title: Text(title),
                content: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        thickness: 4,
                        radius: Radius.circular(10),
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Wrap(
                                spacing: 8.0,
                                children: elements.map((element) {
                                  final isSelected =
                                      selectedElements.contains(element['id']);
                                  return GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        if (isSelected) {
                                          selectedElements
                                              .remove(element['id']);
                                        } else {
                                          selectedElements.add(element['id']);
                                        }
                                      });
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSecondary
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 6,
                                        children: [
                                          Icon(
                                            element['icon']?.icon ??
                                                Icons.help_outline,
                                            size: 22,
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .tertiary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onTertiary,
                                          ),
                                          Text(
                                            element['name'],
                                            style: TextStyle(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .tertiary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onTertiary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList())))));
          },
        ),
      );
}
