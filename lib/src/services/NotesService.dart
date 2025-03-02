import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';
import 'package:moodify/src/services/MentalService.dart';

class NotesService {

  NotesService._privateConstructor();

  static final NotesService _instance = NotesService._privateConstructor();

  static NotesService get instance => _instance;

  final SupabaseClient supabase = Supabase.instance.client;

  final MentalService ms = MentalService();

  Future<List<Map<String, dynamic>>> fetchActivities() async {
  try {
    final response = await supabase.from('activities').select('*');
    log("Fetched activities: $response");

    // Remapowanie kluczy
    return response.map((element) {
      return {
        'id': element['id'] as int,
        'name': element['activity_name'] as String,
      };
    }).toList();
  } catch (e) {
    log("Error reading activities: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchEmotions() async {
  try {
    final response = await supabase.from('emotions').select('*');
    log("Fetched emotions: $response");

    // Remapowanie kluczy
    return response.map((element) {
      return {
        'id': element['id'] as int,
        'name': element['emotion_name'] as String,
      };
    }).toList();
  } catch (e) {
    log("Error reading emotions: $e");
    return [];
  }
  }


  Future<void> saveNote(int mood, List<int> emotions, List<int> activities, String note) async
  {
    final List<double> scores = await ms.assess(note);
    // Insert to notes table
    final notesResponse = await supabase
    .from('notes')
    .insert([
      { 'user_id': UserService.instance.user_id, 'mood': mood, 'note':note, 'scores': scores },
    ])
    .select();

    int noteId = notesResponse[0]['id'];

    log("Added note $noteId!");


    // Insert to notes_emotions
    await supabase
    .from('notes_emotions')
    .insert(emotions.map((emotion)
    {
      return {'emotion_id': emotion, 'note_id': noteId};
    }).toList());

    log("Added emotions $emotions to note $noteId");
    // Insert to notes_activities
      await supabase
      .from('notes_activities')
      .insert(activities.map((activity)
      {
        return {'activity_id': activity, 'note_id': noteId};
      }).toList());
    log("Added activities $activities to note $noteId");
    }

}