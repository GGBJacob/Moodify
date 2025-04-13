import 'package:moodify/src/utils/Pair.dart';
/// Creates a summary of notes from the database response
/// Every list contains pairs of (key, value) where key is the name of the mood/emotion/activity and value is the count of notes with that mood/emotion/activity.
class NotesSummary {
  final List<Pair<int, int>>? moods;
  final List<Pair<String, int>>? emotions;
  final List<Pair<String, int>>? activities;
  final Set<DateTime>? activeDays;

  NotesSummary({
    this.moods,
    this.emotions,
    this.activities,
    this.activeDays
  });

  factory NotesSummary.fromRaw(List<Map<String, dynamic>> rawData) {
  
  final Map<int, int> moodCounts = {};
  final Map<String, int> emotionCounts = {};
  final Map<String, int> activityCounts = {};
  final Set<DateTime> activeDays = {};

  for (var note in rawData) {
    int mood = note['mood'];
    moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;

    DateTime date = DateTime.parse(note['created_at']);
    date.toLocal();
    DateTime simplifiedDate = DateTime(date.year, date.month, date.day);
    activeDays.add(simplifiedDate);

    List emotions = note['notes_emotions'] ?? [];
    for (var e in emotions) {
      String emotion = e['emotions']['emotion_name'];
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    List activities = note['notes_activities'] ?? [];
    for (var a in activities) {
      String activity = a['activities']['activity_name'];
      activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
    }
  }

  return NotesSummary(
    moods: moodCounts.entries
        .map((entry) => Pair(entry.key, entry.value))
        .toList(),
    emotions: emotionCounts.entries
        .map((entry) => Pair(entry.key, entry.value))
        .toList(),
    activities: activityCounts.entries
        .map((entry) => Pair(entry.key, entry.value))
        .toList(),
    activeDays: activeDays.toSet()
    );
    }

  Map<String, dynamic> toJson() => {
    'moods': moods,
    'emotions': emotions,
    'activities': activities,
  };

  List<String> topEmotions(int topCount) {
  if (emotions == null || emotions!.isEmpty) return [];

  final sorted = [...emotions!]
    ..sort((a, b) => b.second.compareTo(a.second));

  return sorted
      .take(topCount)
      .map((e) => e.first)
      .toList();
  }

  List<String> topActivities(int topCount) {
  if (activities == null || activities!.isEmpty) return [];

  final sorted = [...activities!]
    ..sort((a, b) => b.second.compareTo(a.second));

  return sorted
      .take(topCount)
      .map((e) => e.first)
      .toList();
  }

  double averageMood()
  {
    if (moods == null || moods!.isEmpty) return 0;
    int totalMood = 0;
    int count = 0;
    for (var mood in moods!)
    {
      totalMood += mood.first * mood.second;
      count += mood.second;
    }
    return totalMood/count;
  }

  bool get isEmpty =>
      (moods == null && moods!.isEmpty) && (emotions != null && emotions!.isEmpty) && (activities!=null && activities!.isEmpty);

  bool wasUserActiveToday()
  {
    if (activeDays == null || activeDays!.isEmpty) return false;
    DateTime today = DateTime.now().toLocal();
    DateTime simplifiedToday = DateTime(today.year, today.month, today.day);
    return activeDays!.contains(simplifiedToday);
  }
}
