import 'dart:collection';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moodify/src/models/NotesSummary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'UserService.dart';
import 'package:moodify/src/services/MentalService.dart';

class DatabaseService {

  DatabaseService._privateConstructor();

  static final DatabaseService _instance = DatabaseService._privateConstructor();

  final StreamController<void> _updateController = StreamController.broadcast(); //notifier

  Stream<void> get updates => _updateController.stream;

  static DatabaseService get instance => _instance;

  final SupabaseClient supabase = Supabase.instance.client;

  final MentalService ms = MentalService();

  bool streakActive = false;
  int? streakValue;

  Future<bool> testConnection() async{
    try{
      await supabase.from('emotions').select().limit(1);
      return true;
    }
    on SocketException catch(_)
    {
      return false;
    }catch (e)
    {
      log("Error while testing connection: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivities() async {
  try {
    final response = await supabase.from('activities').select('*');
    log("Fetched activities: $response");

    // Remapowanie kluczy
    return response.map((element) {
      return {
        'id': element['id'] as int,
        'name': element['activity_name'] as String,
        'icon': element['activity_icon']!= null ? Icon(IconData(int.parse(element['activity_icon'], radix:16), fontFamily: 'MaterialIcons')) : null,
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
        'icon': element['emotion_icon']!= null ? Icon(IconData(int.parse(element['emotion_icon'], radix:16), fontFamily: 'MaterialIcons')) : null,
      };
    }).toList();
  } catch (e) {
    log("Error reading emotions: $e");
    return [];
  }
  }


  Future<int?> saveNote(int mood, List<int> emotions, List<int> activities, String note) async
  {
    try{
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

       if (!streakActive)
      {
        _updateStreak();
        streakActive = true;
      }

      _updateController.add(null); //notify calendar

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
      
      return noteId;
    }
    catch(e){
      log("Error while saving note: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotes(DateTime startDate, DateTime endDate) async {
    String user_id = UserService.instance.user_id;

    // Fetch notes belonging to users betwen startDate and endDate
    try {
      final response = await Supabase.instance.client
          .from('notes')
          .select('''
        id,
        created_at,
        mood,
        notes_emotions(emotions(emotion_name, emotion_icon)),
        notes_activities(activities(activity_name, activity_icon)),
        note
    ''')
          .eq('user_id', user_id)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      log("Response: $response");
      return response;
    } catch (e) {
      log("Error while fetching user's notes: $e");
      return [];
    }
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  Map<DateTime, List<Map<String, dynamic>>> groupNotesByDate(List<Map<String, dynamic>> notesList) {

    final Map<DateTime, List<Map<String, dynamic>>> groupedNotes = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    for (var note in notesList) {
      final createdAt = DateTime.parse(note['created_at']).toLocal();

      final timeOnly = '${createdAt.hour.toString()}:${createdAt.minute.toString().padLeft(2, '0')}';
      note['time'] = timeOnly;

      final dateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (!groupedNotes.containsKey(dateOnly)) {
        groupedNotes[dateOnly] = [];
      }
      groupedNotes[dateOnly]!.add(note);
    }

    return groupedNotes;
  }

  Future<List<Map<String, dynamic>>> fetchTestResults(DateTime startDate, DateTime endDate) async {

    String user_id = UserService.instance.user_id;
    try{
      final response = await Supabase.instance.client
        .from('phq-9_results')
        .select('''
        created_at,
        points,
        answers
        ''')
        .eq('user_id', user_id)
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());
      return response;
    } catch(e)
    {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchWeeklyNoteDetails(
      DateTime startOfWeek,
      DateTime endOfWeek) async
  {
    try {

    String userId = UserService.instance.user_id;

    // Fetch element count for this week
    return await Supabase.instance.client
        .from('notes')
        .select('''
        mood,
        created_at,
        notes_emotions(emotions(emotion_name)),
        notes_activities(activities(activity_name))
        ''')
        .eq('user_id', userId)
        .gte('created_at', startOfWeek.toIso8601String())
        .lte('created_at', endOfWeek.toIso8601String());
    }catch(e)
    {
      log("Error fetching week summary: $e");
      return [];
    }
  }


  Future<NotesSummary> fetchWeekSummary() async {
    DateTime now = DateTime.now();
    // Calculate the start of the week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = now;
    try {
      var rawDetails = await _fetchWeeklyNoteDetails(startOfWeek, endOfWeek);
      NotesSummary result = NotesSummary.fromRaw(rawDetails);
      return result;
    } catch (e) {
      log("Error fetching week summary: $e");
      return NotesSummary(
        moods: [],
        emotions: [],
        activities: [],
      );
    }
  }

  Future<NotesSummary> fetchPreviousWeekSummary() async
  {
    DateTime now = DateTime.now();
    DateTime endOfWeek = now.subtract(Duration(days: now.weekday));
    DateTime startOfWeek = endOfWeek.subtract(Duration(days:6));
    
    try{
      var rawDetails = await _fetchWeeklyNoteDetails(startOfWeek, endOfWeek);
      return NotesSummary.fromRaw(rawDetails);
      // [await _fetchAndCountWeeklyElements(null, 'moods', 'mood', startOfWeek, endOfWeek)];
    }
    catch(e)
    {
      log("Error fetching previous week sumary: $e");
      return NotesSummary(
        moods: [],
        emotions: [],
        activities: [],
      );
    }
  }

  
  Future<Map<int, int>> fetchAndCountMonthMoods(DateTime date) async
  {
    try {
    DateTime now = DateTime.now();

    DateTime startOfMonth = DateTime(date.year, date.month, 1);

    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0); //"zero" day is last day of moth

    if (endOfMonth.isAfter(now))
    {
      endOfMonth = now;
    }

    String userId = UserService.instance.user_id;

    final response = await Supabase.instance.client
          .from('notes')
          .select('mood, created_at')
          .eq('user_id', userId)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at', ascending: true);

      if (response.isEmpty) {
        return {};
      }

      Map<int, int> moodAverages = {}; 
      DateTime current_date = DateTime.parse(response.first['created_at']);

      int counter = 0;
      int sum = 0;
      for (var item in response) {
        
        DateTime temp_date = DateTime.parse(item['created_at']);
        int mood = item['mood'] as int;

        
        if(temp_date.day == current_date.day)
        {
          sum += mood;
          counter++;
        }
        else 
        {
          moodAverages[current_date.day] = (sum/counter).round();
          sum = mood;
          counter = 1;
          current_date = temp_date;
        }
        
      }

      moodAverages[current_date.day] = (sum/counter).round();

    return  moodAverages;
    } catch (e) {
      log("Error fetching monthly moods: $e");
      return {};
    }
  }

  Future<void> addUserToStreaks(String uuid) async {
    try{
      await supabase
          .from('streaks')
          .insert([
            {'user_id': uuid, 'streak': 0, 'last_time_active': null}
          ]);
      log("Added user to streaks");
    } catch(e) {
      log("Error adding user to streaks: $e");
    }
  }
  
  Future<void> _updateStreak() async{
    try {
    final response = await supabase
      .from('streaks')
      .select('streak')
      .eq('user_id', UserService.instance.user_id);

    final updateResponse = await supabase
        .from('streaks')
        .update({'streak': response[0]['streak']+1, 'last_time_active': DateTime.now().toIso8601String()})
        .eq('user_id', UserService.instance.user_id)
        .select();

    log("Updated streak for user ${UserService.instance.user_id}");

    streakValue = updateResponse[0]['streak'];
  }
    catch(e)
    {
      log("Error updating streak: $e");
    }
  }

  Future<int> loadStreak() async{
    try{
      if (UserService.instance.userInitCompleter != null && !UserService.instance.userInitCompleter!.isCompleted) {
        await UserService.instance.userInitCompleter!.future;
      }
      final response = await supabase
          .from('streaks')
          .select('streak, last_time_active')
          .eq('user_id', UserService.instance.user_id);
      log("Loaded streak: ${response[0]['streak']??0}");
      
      if (response[0]['last_time_active'] == null) {
        return response[0]['streak'];
      }
      
      DateTime lastActive = DateTime.parse(response[0]['last_time_active']);
      if (DateTime.now().toUtc().difference(lastActive.toUtc()).inDays > 1)
      {
        _resetStreak();
        return 0;
      }
      streakValue = response[0]['streak'];
      return response[0]['streak'];
    } catch(e) {
      log("Error loading streak: $e");
      return -1;
    }
  }

  Future<void> _resetStreak() async{
    try{
      final response = await supabase
          .from('streaks')
          .update({'streak': 0})
          .eq('user_id', UserService.instance.user_id);
      log("Streak reset!");
      
      return response[0]['streak'];
    } catch(e) {
      log("Error resetting streak: $e");
    }
  }
}