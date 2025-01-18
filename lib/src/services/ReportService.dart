import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class ReportService {

  Map<int,int> _moodCounts = {};
  Map<String,int> _emotionCounts = {};
  Map<String,int> _activityCounts = {};

  Future<void> generateReport(DateTime startDate, DateTime endDate) async
  {
    String user_id = await UserService.instance.user_id;

    log("Generating report for $user_id");
    // Fetch notes belonging to users betwen startDate and endDate
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

    getCounts(response);
    sortCounts();
    log("Moods: $_moodCounts");
    log("Emotions: $_emotionCounts");
    log("Activities: $_activityCounts");
  }

  void getCounts(List<Map<String,dynamic>> response)
  {
    for (final item in response) {
      // Count moods
      final mood = item['mood'] as int;
      _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;

      // Count emotions
      for (final notesEmotions in item['notes_emotions']){
        final emotionName = notesEmotions['emotions']['emotion_name'] as String;
        _emotionCounts[emotionName] = (_emotionCounts[emotionName] ?? 0) + 1;
      }

      // Count activities
      for (final notesActivities in item['notes_activities']) {
        final activityName = notesActivities['activities']['activity_name'] as String;
        _activityCounts[activityName] = (_activityCounts[activityName] ?? 0) + 1;
      }
    }
  }

  Map<K, int> sortCount<K>(Map<K, int> counts) {
    var sortedEntries = counts.entries.toList()
    ..sort((e1, e2) => e2.value.compareTo(e1.value)); // Sort descending
    return Map.fromEntries(sortedEntries);
  }

  void sortCounts()
  {
    _activityCounts = sortCount(_activityCounts);
    _emotionCounts = sortCount(_emotionCounts);
    _moodCounts = sortCount(_moodCounts);
  }

}