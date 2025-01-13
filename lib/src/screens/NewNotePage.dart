import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';

/*
TODO:
  1. Add validation for mood section (necessary for saving)
  2. Add popup for Emotions
  3. Add popup for Activities
  4. Make the page nice
 */

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();

}

class _NewNotePageState extends State<NewNotePage>
{
  DateTime _now = DateTime.now();

  GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();
  int? _idMood;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
          child:
          Column(
            children: [
          SizedBox(height:20),
              CustomBlock(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,  //spaces all children evenly in vertical axis

            children: [
              Form(
                key: _formGlobalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(style: TextStyle(fontSize: 45),'25th May 2025'),

                    //Mood
                    Text(style: TextStyle(fontSize: 30),'Mood:'),
                    _moods(),
                    SizedBox(height:20),

                    //Emotions
                    Text(style: TextStyle(fontSize: 30),'Emotions:'),
                    Center(
                      child: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.add_circle_outline_rounded, size: 50,)
                      )
                    ),
                    SizedBox(height:20),

                    //Activities
                    Text(style: TextStyle(fontSize: 30),'Activities:'),
                    Center(
                        child: IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.add_circle_outline_rounded, size: 50,)
                        )
                    ),
                    SizedBox(height:20),

                    //Note
                    Text(style: TextStyle(fontSize: 30),'Note:'),
                    TextFormField(
                      decoration: InputDecoration(labelText: "How was your day?",
                        border: OutlineInputBorder()),
                      maxLength: 1000,
                    ),

                    SizedBox(height:20),

                    //save button
                    ElevatedButton(
                        onPressed: (){
                          if(_formGlobalKey.currentState!.validate()){
                            _formGlobalKey.currentState!.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Added!")),
                            );
                          }
                        },
                        child: Text("Save"),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)
                          )
                        )
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
    );
  }

  Widget _moods() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: (){
            setState(() {
              _idMood = 0;
            });
          },
          child: Icon(
            Icons.sentiment_very_satisfied_rounded,
            size: 50,
            color: _idMood == 0 ? Colors.green : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _idMood = 1;
            });
          },
          child: Icon(
            Icons.sentiment_neutral_rounded,
            size: 50,
            color: _idMood == 1 ? Colors.orange : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: (){
            setState(() {
              _idMood = 2;
            });
          },
          child: Icon(
            Icons.sentiment_very_dissatisfied_rounded,
            size: 50,
            color: _idMood == 2 ? Colors.red : Colors.grey,
          ),
        )
      ],
    );
  }
}