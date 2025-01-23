import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class ReportService {
  Map<int, int> _moodCounts = {};
  Map<String, int> _emotionCounts = {};
  Map<String, int> _activityCounts = {};
  int _noteCount = 0, _notesSkipped = 0;
  DateTime _startDate=DateTime(2025,1,20), _endDate = DateTime.now();


  void init(DateTime startDate, DateTime endDate)
  {
    _startDate = startDate;
    _endDate = endDate;
  }


  Future<List<Map<String, dynamic>>> prepareReport() async {
    String user_id = await UserService.instance.user_id;

    log("Generating report for $user_id");
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
          .gte('created_at', _startDate.toIso8601String())
          .lte('created_at', _endDate.toIso8601String());

      log("Response: $response");

      getCounts(response);
      sortCounts();
      log("Moods: $_moodCounts");
      log("Emotions: $_emotionCounts");
      log("Activities: $_activityCounts");
      return response;
    } catch (e) {
      log("Error while fetching user's notes: $e");
      return [];
    }
  }

  void getCounts(List<Map<String, dynamic>> response) {
    _noteCount = response.length;
    _notesSkipped = DateTime.now().difference(_startDate).inDays - _noteCount + 1;


    for (final item in response) {
      // Count moods
      final mood = item['mood'] as int;
      _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;

      // Count emotions
      for (final notesEmotions in item['notes_emotions']) {
        final emotionName = notesEmotions['emotions']['emotion_name'] as String;
        _emotionCounts[emotionName] = (_emotionCounts[emotionName] ?? 0) + 1;
      }

      // Count activities
      for (final notesActivities in item['notes_activities']) {
        final activityName =
            notesActivities['activities']['activity_name'] as String;
        _activityCounts[activityName] =
            (_activityCounts[activityName] ?? 0) + 1;
      }
    }
  }

  Map<K, int> sortCount<K>(Map<K, int> counts) {
    var sortedEntries = counts.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)); // Sort descending
    return Map.fromEntries(sortedEntries);
  }

  void sortCounts() {
    _activityCounts = sortCount(_activityCounts);
    _emotionCounts = sortCount(_emotionCounts);
    _moodCounts = sortCount(_moodCounts);
  }

  pw.Chart? _pieChart(pw.Text title, Map<String, int> dataset, int itemCount) {
    const chartColors = [
      PdfColors.blue300,
      PdfColors.green300,
      PdfColors.amber300,
      PdfColors.pink300,
      PdfColors.cyan300,
      PdfColors.purple300,
      PdfColors.lime300,
    ];

    if (itemCount > dataset.length) {
      itemCount = dataset.length; // select max dataset.length items
    }

    if (itemCount > chartColors.length) {
      itemCount = chartColors.length -
          1; // If more items are to be selected, remaining will be marked as other with the last color
    }

    final dataExtracted = dataset.entries.take(itemCount).toList();
    int dataCount = 0, otherDataCount = 0;

    // Count all values in selected period
    dataset.forEach((key, value) {
      dataCount += value;
    });

    if (dataCount == 0) {
      return null;
    }

    // Count selected values to later obtain 'other' size
    for (var i in dataExtracted) {
      otherDataCount += i.value;
    }
    // Calculate 'other' category size
    otherDataCount = dataCount - otherDataCount;

    // Add others to list
    if (otherDataCount > 0) {
      dataExtracted.add(MapEntry('Other', otherDataCount));
    }

    return pw.Chart(
      title: title,
      bottom: pw.ChartLegend(direction: pw.Axis.horizontal),
      grid: pw.PieGrid(),
      datasets: List<pw.Dataset>.generate(dataExtracted.length, (index) {
        final MapEntry<String, int> element = dataExtracted.elementAt(index);
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

  pw.Chart? _moodLineChart(List<Map<String, dynamic>> response) {
    // Generate dates
    final List<DateTime> dateList = List.generate(
        _endDate.difference(_startDate).inDays + 1,
        (index) => _startDate.add(Duration(days: index)));

    // Generate which dates to show
    final int numberOfLabels =
        10 < dateList.length ? 10 : dateList.length; // Must be >2
    final List<int> dateIndices = List.generate(numberOfLabels, (i) {
      return ((i * (dateList.length - 1)) / (numberOfLabels - 1)).round();
    });

    // Extract dates and moods only
    final Map<DateTime, int> moodList = {
      for (var entry in response)
        DateTime.parse(entry['created_at'] as String).toLocal().copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0): entry['mood'] as int
    };

    // Assign colors to moods - TODO
    final List<dynamic> moodLineColors = [
      PdfColor.fromHex('FF840303'),
      PdfColors.red300,
      PdfColors.orange300,
      PdfColor.fromHex('FF91AE00'),
      PdfColors.green
    ];

    // Draw chart
    try {
      final chart = pw.Chart(
          left: pw.Container(
            alignment: pw.Alignment.topCenter,
            margin: const pw.EdgeInsets.only(right: 5, top: 60),
              child: pw.Transform.rotateBox(
                  angle: 3.14 / 2,
                  child: pw.Text('Mood',
                      style: pw.TextStyle(
                          font: pw.Font.timesBold(), fontSize: 20)))),
          bottom: pw.Text('Note date',
              style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 20)),
          grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis(
                  // Generate a list for xAxis
                  List.generate(dateList.length, (index) => index.toDouble()),
                  divisions: true, format: (index) {
                if (dateIndices.contains(index)) {
                  final date = dateList[index.toInt()];
                  return '${date.month}/${date.day}'; // Format date
                } else {
                  return '';
                }
              }, angle: 3.14 / 6),
              yAxis: pw.FixedAxis([0, 1, 2, 3, 4],
                  divisions: true) // Assign fixed mood values to yAxis
              ),
          datasets: [
            pw.LineDataSet(
              data: List<pw.PointChartValue>.generate(dateList.length, (index) {
                // Assign values to corresponding dates on the chart
                final date = dateList[index];
                final mood = moodList[date];
                return pw.PointChartValue(
                    index.toDouble(), mood?.toDouble() ?? -1.0);
              }),
              drawSurface: true,
              isCurved: true,
              drawPoints: false,
            )
          ]);
      return chart;
    } catch (e) {
      log("Exception: $e");
      return null;
    }
  }

  Future<Uint8List> generateReport() async {
    final response = await prepareReport();

    /*final response = [
  {
    "id": 5,
    "created_at": "2025-01-03T12:27:45.954151+00:00",
    "mood": 4,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Angry"}},
      {"emotions": {"emotion_name": "Calm"}},
      {"emotions": {"emotion_name": "Sad"}}
    ]
  },
  {
    "id": 6,
    "created_at": "2025-01-04T09:15:30.123456+00:00",
    "mood": 3,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Happy"}},
      {"emotions": {"emotion_name": "Excited"}}
    ]
  },
  {
    "id": 7,
    "created_at": "2025-01-06T14:45:00.654321+00:00",
    "mood": 2,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Calm"}},
      {"emotions": {"emotion_name": "Neutral"}}
    ]
  },
  {
    "id": 8,
    "created_at": "2025-01-10T18:30:10.789012+00:00",
    "mood": 1,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Tired"}},
      {"emotions": {"emotion_name": "Sad"}}
    ]
  },
  {
    "id": 9,
    "created_at": "2025-01-12T11:30:10.789012+00:00",
    "mood": 3,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Happy"}},
      {"emotions": {"emotion_name": "Excited"}}
    ]
  },
  {
    "id": 10,
    "created_at": "2025-01-15T08:30:10.789012+00:00",
    "mood": 2,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Sad"}},
      {"emotions": {"emotion_name": "Tired"}}
    ]
  },
  {
    "id": 11,
    "created_at": "2025-01-17T16:30:10.789012+00:00",
    "mood": 4,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Angry"}},
      {"emotions": {"emotion_name": "Excited"}}
    ]
  },
  {
    "id": 12,
    "created_at": "2025-01-20T14:30:10.789012+00:00",
    "mood": 3,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Calm"}},
      {"emotions": {"emotion_name": "Sad"}}
    ]
  },
  {
    "id": 13,
    "created_at": "2025-01-22T10:30:10.789012+00:00",
    "mood": 2,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Neutral"}},
      {"emotions": {"emotion_name": "Tired"}}
    ]
  },
  {
    "id": 14,
    "created_at": "2025-01-24T12:30:10.789012+00:00",
    "mood": 1,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Sad"}},
      {"emotions": {"emotion_name": "Tired"}}
    ]
  },
  {
    "id": 15,
    "created_at": "2025-01-28T17:30:10.789012+00:00",
    "mood": 4,
    "notes_emotions": [
      {"emotions": {"emotion_name": "Happy"}},
      {"emotions": {"emotion_name": "Excited"}}
    ]
  }
];
    */

    //final moodifyData = await rootBundle.load('assets/moodify_logo.jpg');
    //final moodifyImage = pw.MemoryImage(moodifyData.buffer.asUint8List());

    final List<List<dynamic>> moodPairs = [
      [Icons.sentiment_very_dissatisfied_rounded, Color(0xFF840303)],
      [Icons.sentiment_dissatisfied_rounded, Colors.red],
      [Icons.sentiment_neutral_rounded, Colors.orange],
      [Icons.sentiment_satisfied_rounded, Color(0xFF91AE00)],
      [Icons.sentiment_very_satisfied_rounded, Colors.green]
    ];

    // Emotion pie chart title
    final pw.Text emotionChartTitle = pw.Text("Selected emotions",
        style: pw.TextStyle(font: pw.Font.times(), fontSize: 30));

    // Activity pie chart title
    final pw.Text activityChartTitle = pw.Text("Selected activities",
        style: pw.TextStyle(font: pw.Font.times(), fontSize: 30));

    final double chartSize = 240;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Report title
            pw.Container(
                margin: pw.EdgeInsets.all(15),
                child: pw.Text(
                  'Note report',
                  style: pw.TextStyle(
                    font: pw.Font.timesBold(),
                    fontSize: 60,
                  ),
                )),

            pw.Text(
              'Notes filled: $_noteCount\nNotes skipped: $_notesSkipped',
              style: pw.TextStyle(font: pw.Font.times(), fontSize: 30),
            ),

            

            pw.SizedBox(
                child: _moodLineChart(response),
                height: chartSize,
                width: chartSize * 2),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: _pieChart(activityChartTitle, _activityCounts, 5),
                ),
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

  Future<void> saveReport() async {
    try {
      final fileContent =
          await generateReport();

      // TODO: This code works poorly, changes needed in the future (probably for path_provider)
      await FilePicker.platform.saveFile(
          dialogTitle: "Choose Save Location",
          fileName: "report.pdf",
          bytes: Uint8List.fromList(fileContent));
    } catch (e, stacktrace) {
      log("Error saving file: $e");
      log('$stacktrace');
    }
  }
}
