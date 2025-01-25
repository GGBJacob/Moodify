import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class NotesService {

  NotesService._privateConstructor();

  static final NotesService _instance = NotesService._privateConstructor();

  static NotesService get instance => _instance;

  final SupabaseClient supabase = UserService.instance.supabase;

  Future<List<Map<String, dynamic>>> fetchActivities() async {
  try {
    final response = await supabase.from('activities').select('*');

    // Remapowanie kluczy
    return response.map((element) {
      return {
        'id': element['id'] as int,
        'name': element['activity_name'] as String,
      };
    }).toList();
  } catch (e) {
    print("Error reading activities: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchEmotions() async {
  try {
    final response = await supabase.from('emotions').select('*');

    // Remapowanie kluczy
    return response.map((element) {
      return {
        'id': element['id'] as int,
        'name': element['emotion_name'] as String,
      };
    }).toList();
  } catch (e) {
    print("Error reading emotions: $e");
    return [];
  }
  }


  Future<void> saveNote(int mood, List<int> emotions, List<int> activities, String note) async
  {
    // Insert to notes table
    final notesResponse = await supabase
    .from('notes')
    .insert([
      { 'user_id': UserService.instance.user_id, 'mood': mood, 'note':note },
    ])
    .select();

    int noteId = notesResponse[0]['id'];

    print("Added note $noteId!");

    // Insert to notes_emotions
    await supabase
    .from('notes_emotions')
    .insert(emotions.map((emotion)
    {
      return {'emotion_id': emotion, 'note_id': noteId};
    }).toList());


    // Insert to notes_activities
      await supabase
      .from('notes_activities')
      .insert(activities.map((activity)
      {
        return {'activity_id': activity, 'note_id': noteId};
      }).toList());

    }

}