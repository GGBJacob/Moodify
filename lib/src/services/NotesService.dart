import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class NotesService {

  NotesService._privateConstructor();

  static final NotesService _instance = NotesService._privateConstructor();

  static NotesService get instance => _instance;

  final SupabaseClient supabase = Supabase.instance.client;

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
    log("Adding note...");
    // Insert to notes table
    final notes_response = await supabase
    .from('notes')
    .insert([
      { 'user_id': await UserService.instance.user_id, 'mood': mood, 'note':note },
    ])
    .select();

    int note_id = notes_response[0]['id'];

    log("Added note $note_id!");

    // Insert to notes_emotions
    await supabase
    .from('notes_emotions')
    .insert(emotions.map((emotion)
    {
      return {'emotion_id': emotion, 'note_id': note_id};
    }).toList());

    log("Added emotions $emotions to note $note_id");
    // Insert to notes_activities
      await supabase
      .from('notes_activities')
      .insert(activities.map((activity)
      {
        return {'activity_id': activity, 'note_id': note_id};
      }).toList());
    log("Added activities $activities to note $note_id");
    }

}