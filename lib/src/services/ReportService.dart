import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:moodify/src/services/TestService.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class ReportService {
  Map<int, int> _moodCounts = {};
  Map<String, int> _emotionCounts = {};
  Map<String, int> _activityCounts = {};
  int _noteCount = 0, _notesSkipped = 0;
  DateTime _startDate = DateTime(2025, 1, 20), _endDate = DateTime.now();

  void init(DateTime startDate, DateTime endDate) {
    _startDate = DateTime(startDate.year, startDate.month, startDate.day);
    _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59);
  }

  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    String user_id = await UserService.instance.getOrGenerateUserId();

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
    _notesSkipped =
        DateTime.now().difference(_startDate).inDays - _noteCount + 1;

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

  pw.Chart? _pieChart(pw.Widget title, Map<String, int> dataset, int itemCount) {
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

    final pw.Widget chartTitle = pw.Center(
      child: pw.Container(
        child: pw.Text(
          "Selected mood chart",
          style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)
        )
      )
    );

    // Draw chart
    try {
      final chart = pw.Chart(
        title: chartTitle,
          left: pw.Container(
              alignment: pw.Alignment.topCenter,
              margin: const pw.EdgeInsets.only(right: 5, top: 60),
              child: pw.Transform.rotateBox(
                  angle: 3.14 / 2,
                  child: pw.Text('Mood',
                      style: pw.TextStyle(
                          font: pw.Font.times(), fontSize: 20)))),
          bottom: pw.Text('Note date',
              style: pw.TextStyle(font: pw.Font.times(), fontSize: 20)),
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

  Future<List<Map<String, dynamic>>> _fetchTestResults() async {

    String user_id = await UserService.instance.getOrGenerateUserId();
    try{
      final response = await Supabase.instance.client
        .from('phq-9_results')
        .select('''
        created_at,
        points,
        answers
        ''')
        .eq('user_id', user_id)
        .gte('created_at', _startDate.toIso8601String())
        .lte('created_at', _endDate.toIso8601String());
      return response;
    } catch(e)
    {
      return [];
    }
  }

  pw.Widget _testResultsTable(List<Map<String,dynamic>> testResults)
  {
      const List<String> tableHeaders = [
        "Date submitted",
        "Score"
      ];

      const List<String> testResultKeys = [
        "created_at",
        "points"
      ];

      return pw.TableHelper.fromTextArray(
        
        headerHeight: 25,
        cellHeight: 35,

        headers: List<String>.generate(
          tableHeaders.length,
          (col) => tableHeaders[col],
        ),

        data: List<List<String>>.generate(
          testResults.length,
          (row) => List<String>.generate(
            tableHeaders.length,
            (col) { 
              final key = testResultKeys[col];
              final value = testResults[row][key];
              if (key == "created_at")
              {
                final date = DateTime.parse(value).toLocal();
                final dateText = date.toString();
                return dateText.substring(0, dateText.length-7); // Remove miliseconds (more readable way than getting all date fragments)
              }
              else if (value is int)
              {
                return value.toString();
              }
              else if (value is String)
              {
                return value;
              }
              else 
              {
                return '';
              }
            }
          )
        )
      );
  }

  Future<Uint8List> generateReport() async {
    final notesResponse = await _fetchNotes();
    final testResultsResponse = await _fetchTestResults();


    final pdf = pw.Document();
    pdf.addPage(
      _firstPage(notesResponse)
    );

    if (testResultsResponse.isEmpty)
    {
      return pdf.save();
    }

    pdf.addPage(
      _testResultPages(testResultsResponse)
    );

    return pdf.save();
  }

  pw.Page _firstPage(List<Map<String,dynamic>> notesResponse)
  {
    // Emotion pie chart title
    final pw.Widget emotionChartTitle = pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        "Selected emotions",
        style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)));

    // Activity pie chart title
    final pw.Widget activityChartTitle = pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        "Selected activities",
        style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)));

    const double chartSize = 240;
    return pw.Page(
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
                  fontSize: 50,
                ),
              )),

          pw.Text(
            'Notes filled: $_noteCount\nNotes skipped: $_notesSkipped',
            style: pw.TextStyle(font: pw.Font.times(), fontSize: 30),
          ),

          pw.SizedBox(
              child: _moodLineChart(notesResponse),
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
          pw.SizedBox(height: 10)
        ],
      ),
    );
  }

  pw.MultiPage _testResultPages(List<Map<String,dynamic>> response)
  {
    return pw.MultiPage(
      build:(context) {
        List<pw.Widget> content = [
          pw.Center(child: pw.Container(
            margin: pw.EdgeInsets.only(bottom: 15),
            child: pw.Text(
            'PHQ-9 summary',
            style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 50),
            
          ))),
          _testResultsTable(response),
          pw.SizedBox(height: 30),
          _testResultsChart(response)
        ];

        return content;
      }
    );
  }

  pw.Widget _testResultsChart(List<Map<String, dynamic>> response) {
    const double chartSize = 300;

    final processedResponse = response.map((entry) {
      final bits = entry['answers'] as String;
      return TestService.instance.convertBitsToAnswers(bits);
    }).toList();

    final averageAnswerScore = List<double>.generate(
        processedResponse[0].length,
        (col) =>
            processedResponse.map((row) => row[col]).reduce((a, b) => a + b) /
            processedResponse.length);

    final pw.Widget chartTitle = pw.Center(
      child: pw.Container(
        margin: pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(
          'Average question score',
          style: pw.TextStyle(font: pw.Font.times(), fontSize: 30)
        )
      )
    );

    return pw.Center(
        child: pw.SizedBox(
            height: chartSize,
            child: pw.Chart(
              title: chartTitle,
              left: pw.Container(
                alignment: pw.Alignment.topCenter,
                margin: const pw.EdgeInsets.only(right: 5, top: 10),
                child: pw.Transform.rotateBox(
                  angle: 3.14 / 2,
                  child: pw.Text('Average score'),
                ),
              ),
              bottom: pw.Container(
                  alignment: pw.Alignment.center,
                  margin: const pw.EdgeInsets.only(top: 5),
                  child: pw.Text('Question number')),
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis.fromStrings(
                  List<String>.generate(9, (index) => (index + 1).toString()),
                  marginStart: 30,
                  marginEnd: 30,
                  ticks: true,
                ),
                yAxis: pw.FixedAxis(
                  [0, 1, 2, 3],
                  divisions: true,
                ),
              ),
              datasets: [
                pw.BarDataSet(
                  color: PdfColors.blue100,
                  width: 15,
                  borderColor: PdfColors.cyan,
                  data: List<pw.PointChartValue>.generate(
                    averageAnswerScore.length,
                    (i) {
                      final v = averageAnswerScore[i] as num;
                      return pw.PointChartValue(i.toDouble(), v.toDouble());
                    },
                  ),
                )
              ],
            )
          )
        );
  }

  Future<int> saveReport() async {
    try {
      final fileContent = await generateReport();

      // TODO: This code works poorly, changes needed in the future (probably for path_provider)
      final response = await FilePicker.platform.saveFile(
          dialogTitle: "Choose Save Location",
          fileName: "report.pdf",
          bytes: Uint8List.fromList(fileContent));

      log("Response: $response");

      if (response == null) {
        return -1;
      }

      return 0;
    } catch (e, stacktrace) {
      log("Error saving file: $e");
      log('$stacktrace');
      return -1;
    }
  }
}
