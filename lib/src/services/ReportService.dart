import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class ReportService {

  Map<int,int> _moodCounts = {};
  Map<String,int> _emotionCounts = {};
  Map<String,int> _activityCounts = {};
  int _noteCount = 0;

  Future<void> prepareReport(DateTime startDate, DateTime endDate) async
  {
    String user_id = await UserService.instance.user_id;

    log("Generating report for $user_id");
    // Fetch notes belonging to users betwen startDate and endDate
    try{
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
    }catch(e)
    {
      log("Error while fetching user's notes: $e");
    }
  }

  void getCounts(List<Map<String,dynamic>> response)
  {
    _noteCount = response.length;

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

  pw.Chart _pieChart(pw.Text title, Map<String, int> dataset, int itemCount)
  {
    const chartColors = [
          PdfColors.blue300,
          PdfColors.green300,
          PdfColors.amber300,
          PdfColors.pink300,
          PdfColors.cyan300,
          PdfColors.purple300,
          PdfColors.lime300,
        ];

    if (itemCount > dataset.length)
    {
      itemCount = dataset.length; // select max dataset.length items
    }

    if (itemCount > chartColors.length)
    {
      itemCount = chartColors.length-1; // If more items are to be selected, remaining will be marked as other with the last color
    }

    final dataExtracted = dataset.entries.take(itemCount).toList();
    int dataCount = 0, otherDataCount = 0;
    
    // Count all emotions in selected period
    dataset.forEach((key, value){dataCount += value;});
    
    // Count selected emotions to later obtain 'other' size
    for (var i in dataExtracted) {
      otherDataCount += i.value;
    }
    // Calculate 'other' category size
    otherDataCount = dataCount - otherDataCount;

    // Add others to list
    if (otherDataCount > 0){
      dataExtracted.add(MapEntry('Other', otherDataCount));}

    return pw.Chart(
      title: title,
      bottom: pw.ChartLegend(
        direction: pw.Axis.horizontal
      ),
      grid: pw.PieGrid(),
      datasets: List<pw.Dataset>.generate(dataExtracted.length, (index) {
        final MapEntry<String,int> element = dataExtracted.elementAt(index);
        final data = element.key;
        final color = chartColors[index % chartColors.length];
        final value = (element.value).toDouble();
        final pct = (value / dataCount * 100).round();
        return pw.PieDataSet(
          legendPosition: pw.PieLegendPosition.none,
          legend: '$data\n$pct%',
          value: value,
          color: color,
          legendStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
        );
      }),
    );
  }

  Future<Uint8List> generateReport(DateTime startDate, DateTime endDate) async
  {
    await prepareReport(startDate, endDate);

    //final moodifyData = await rootBundle.load('assets/moodify_logo.jpg');
    //final moodifyImage = pw.MemoryImage(moodifyData.buffer.asUint8List());

    final List<List<dynamic>> moodPairs = [
    [Icons.sentiment_very_dissatisfied_rounded, Color(0xFF840303)],
    [Icons.sentiment_dissatisfied_rounded, Colors.red],
    [Icons.sentiment_neutral_rounded, Colors.orange],
    [Icons.sentiment_satisfied_rounded, Color(0xFF91AE00)],
    [Icons.sentiment_very_satisfied_rounded, Colors.green]];

    // Emotion pie chart title
    final pw.Text emotionChartTitle = pw.Text(
      "Selected emotions",
      style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)
    );

    // Activity pie chart title
    final pw.Text activityChartTitle = pw.Text(
      "Selected activities",
      style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)
    );

    final double chartSize = 240;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            // Report title
            pw.Text(
              'User report',
              style: pw.TextStyle(
                font: pw.Font.timesBold(),
                fontSize: 60,
              ),
            ),

            pw.SizedBox(height: 60), 

            pw.Row(
              children: 
                List<pw.Widget>.generate(
                  moodPairs.length,
                  (index)
                  {
                    final moodLabel = _moodCounts[index] ?? "Unknown";
                    return pw.Column(
                      children: [
                        pw.Text(
                          'Mood $index : ${_moodCounts[index] ?? 0}'
                        )]
                    );
                  }
                )
                  /*Icon(
              moodPairs[index][0],
              size: 50,
              color: _selectedMood == index ? moodPairs[index][1] : Colors.grey,
            )*/
            ),

            pw.SizedBox(height: 60), 
            
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center, 
              children: [
                pw.SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: _pieChart(activityChartTitle, _activityCounts, 5),
                ),
                pw.SizedBox(width: 20),

                pw.SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: _pieChart(emotionChartTitle, _emotionCounts, 5),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

}