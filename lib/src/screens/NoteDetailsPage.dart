import 'package:flutter/material.dart';
import 'package:moodify/src/components/CustomBlock.dart';
import 'package:moodify/src/components/PageTemplate.dart';

class NoteDetailsPage extends StatefulWidget {
  final Map<String, dynamic> note; 
  final String date;
  final Image image;
  
  const NoteDetailsPage({super.key, required this.note, required this.date, required this.image});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends State<NoteDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var note = widget.note;
    var date = widget.date;
    var image = widget.image;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(date), 
      ),
      body: SingleChildScrollView(
        child:Center(
          child:Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0), 
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top - 40,
                ),
              child:              
              CustomBlock(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 3.0),
                      child: Row(
                        children: [
                          Image(
                              image: image.image, 
                              width: 70,
                            ),
                          SizedBox(width: 8), 
                          Text(
                            'Note created at: ${note['time']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emotions:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          (note['notes_emotions'] as List).isEmpty
                            ? Text(
                                'No emotions added',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              )
                            : Wrap(
                                spacing: 8.0, 
                                runSpacing: 4.0,
                                children: (note['notes_emotions'] as List<dynamic>).map((emotion) {
                                  String emotionName = emotion['emotions']?['emotion_name'] ?? 'Unknown';
                                  int? codePoint = emotion['emotions']?['emotion_icon'] != null ? int.parse(emotion['emotions']['emotion_icon'], radix:16) : null;
                                  IconData? emotionIcon = codePoint != null
                                    ? IconData(codePoint, fontFamily: 'MaterialIcons')
                                    : Icons.help_outline;
                                  return Chip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(emotionIcon, size: 20, color: Colors.white),
                                        SizedBox(width: 5),
                                        Text(
                                          emotionName,
                                          style: TextStyle(color: Colors.white),
                                        )]),
                                    backgroundColor: Color(0xFF8C4A60), 
                                    labelStyle: TextStyle(color: Colors.white), 
                                  );
                                }).toList(),
                              ),
                        ],
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activities:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    SizedBox(height: 8),
                    (note['notes_activities'] as List).isEmpty
                      ? Text(
                          'No activities added',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        )
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: (note['notes_activities'] as List<dynamic>).map((activity) {
                            String activityName = activity['activities']?['activity_name'] ?? 'Unknown';
                            int? codePoint = activity['activities']?['activity_icon'] != null ? int.parse(activity['activities']['activity_icon'], radix:16) : null;
                            IconData? activityIcon = codePoint != null
                                ? IconData(codePoint, fontFamily: 'MaterialIcons')
                                : Icons.help_outline;
                            return Chip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(activityIcon, size: 20, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    activityName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFF8C4A60),
                            );
                          }).toList(),
                        ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0, left: 3.0),
                      child: Text(
                        'Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.pink[900],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: double.infinity, 
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF0F5), 
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                        (note['note'] ?? '').trim().isNotEmpty ? note['note'].trim() : 'No note added',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          ],
        ),
      )
    ));
  }
}
