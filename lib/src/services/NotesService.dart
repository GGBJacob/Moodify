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
        notes_emotions(emotions(emotion_name)),
        notes_activities(activities(activity_name))
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

  Future<Map<String, dynamic>> _fetchAndCountWeeklyElements(
      String? linkingTable,
      String dataTable,
      String columnName) async
  {
    try {
    DateTime now = DateTime.now();

    // Calculate the start of the week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    DateTime endOfWeek = now;

    String userId = UserService.instance.user_id;

    // Fetch element count for this week
    final response = await Supabase.instance.client
        .from('notes')
        .select( linkingTable != null 
          ? '$linkingTable($dataTable($columnName))'
          : columnName
          )
        .eq('user_id', userId)
        .gte('created_at', startOfWeek.toIso8601String())
        .lte('created_at', endOfWeek.toIso8601String());

    Map<dynamic, int> countsMap = {};

    // Count elements
    for (var item in response)
    {
      if (linkingTable != null) {
        var names = item[linkingTable];
        for (var element in names)
        {
          String name = element[dataTable][columnName] as String;
          countsMap[name] = (countsMap[name] ?? 0) + 1;
        }
      }
      else
      {
        int mood = item[columnName] as int;
        countsMap[mood] = (countsMap[mood] ?? 0) + 1;
      }
      
    }

    
    List<Map<String, dynamic>> sortedList = countsMap.entries
    .map((entry) => {'name': entry.key, 'count': entry.value})
    .toList();

    // Sort elements
    if (linkingTable != null)
    {
      sortedList.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    }
    // Sort moods by value, not count
    else{
      sortedList.sort((a, b) => (b['name'] as int).compareTo(a['name'] as int));
    }
    return {'type': dataTable, 'data': sortedList};

    } catch (e) {
      log("Error fetching week summary: $e");
      return {};
    }
  }


  Future<List<Map<String, dynamic>>> fetchWeekSummary() async {
    try {
      return [
        await _fetchAndCountWeeklyElements('notes_emotions','emotions','emotion_name'),
        await _fetchAndCountWeeklyElements('notes_activities','activities','activity_name'),
        await _fetchAndCountWeeklyElements(null,'moods', 'mood')
      ];
    } catch (e) {
      log("Error fetching week summary: $e");
      return [];
    }
  }

  
  Future<Map<String, dynamic>> fetchAndCountMonthMoods(DateTime date) async
  {
    try {
    DateTime now = DateTime.now();

    // Calculate the start of the week (Monday)
    DateTime startOfMonth = DateTime(date.year, date.month, 1);

    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0); //"zero" day is last day of moth

    if (endOfMonth.isAfter(now))
    {
      endOfMonth = now;
    }

    String userId = UserService.instance.user_id;

    //Data structures
    Map<int, int> monthMoodCount = {}; //Occurence of each of mood in month
    Map<int, Map<int, int>> dailyMoodCount = {}; //Moods of each day
    Map<int, int> dailyMoodAverages = {}; //Average daily mood

   //Iteration by every day of month
    for (int day = 1; day <= endOfMonth.day; day++) {
      DateTime dayStart = DateTime(now.year, now.month, day);
      DateTime dayEnd = dayStart.add(Duration(days: 1)).subtract(Duration(seconds: 1));

      //Fetching daily moods
      final response = await Supabase.instance.client
          .from('notes')
          .select('mood')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String());

      if (response.isNotEmpty) {
        Map<int, int> moodCounts = {}; 

        for (var item in response) {
          int mood = item['mood'] as int;

          monthMoodCount[mood] = (monthMoodCount[mood] ?? 0) + 1; //counting monthly moods

          moodCounts[mood] = (moodCounts[mood] ?? 0) + 1; //counting daily moods
        }

        //Calculating average mood
        int moods_number = 0;
        int moods_sum = 0;

        moodCounts.forEach((mood, count) {
          moods_number += count; // Count all moods
          moods_sum += mood * count; // Sum of moods * their occurrences
        });
        
        // Storing the average mood for the day
        dailyMoodAverages[day] = moods_number > 0 ? (moods_sum / moods_number).round() : 0;

        //Daily moods
        dailyMoodCount[day] = moodCounts;
      }
    }

    return {
      'totalMoodCounts': monthMoodCount,
      'dailyMoodCounts': dailyMoodCount,
      'dailyMoodAverages': dailyMoodAverages
    };
    } catch (e) {
      log("Error fetching monthly moods: $e");
      return {
        'totalMoodCounts': {},
        'dailyMoodCounts': {},
        'dailyMoodAverages': {}
      };
    }
  }
}