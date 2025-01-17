import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class ReportService {

  late Future<List<Map<String,dynamic>>> _notes;
  
  Map<int,int> _moodCounts = {};
  Map<int,int> _emotionCounts = {};
  Map<int,int> _activityCounts = {};

  Future<void> generateReport(DateTime startDate, DateTime endDate) async
  {
    // Fetch notes belonging to users betwen startDate and endDate
    final response = await Supabase.instance.client
    .from('notes')
    .select('mood, emotions(emotion_name), activities(activity_name)')
    .eq('user_id', UserService.instance.user_id)
    .gte('created_at', startDate.toIso8601String())
    .lte('created_at', endDate.toIso8601String());

    _moodCounts = countByKey(response, 'mood');

    _emotionCounts = countByKey(response, 'emotion_name');

    _activityCounts = countByKey(response, 'activity_name');

  }
  
  Map<T, int> countByKey<T>(List<Map<String,dynamic>> items, String key)
  {
    final counts = <T, int>{};

    for (final item in items)
    {
      final value = item[key] as T;
      counts[value] = (counts[value] ?? 0) + 1;
    }

    return counts;
  }

  List<MapEntry<K, int>> sortCounts<K>(Map<K, int> counts) {
    final entries = counts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value)); // Sort malejący
    return entries;
  }

}