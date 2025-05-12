import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:moodify/src/services/DatabaseService.dart';
import 'package:moodify/src/services/TestService.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportService {
  Map<int, int> _moodCounts = {};
  Map<String, int> _emotionCounts = {};
  Map<String, int> _activityCounts = {};
  int _noteCount = 0;
  DateTime _startDate = DateTime(2025, 1, 20), _endDate = DateTime.now();

  void init(DateTime startDate, DateTime endDate) {
    _startDate = DateTime(startDate.year, startDate.month, startDate.day);
    _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59);
  }

  void getCounts(List<Map<String, dynamic>> response) {
    _noteCount = response.length;

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

  pw.Chart? _moodBarChart(List<Map<String, dynamic>> response) {
  final List<DateTime> dateList = List.generate(
    _endDate.difference(_startDate).inDays + 1,
    (index) {
      final date = _startDate.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    },
  );

  final double barWidth = dateList.length <= 7
    ? 30.0
    : dateList.length <= 15
        ? 20.0
        : dateList.length <= 30
            ? 10.0
            : 5.0;


  final Map<DateTime, List<int>> moodsByDay = {};
  for (var entry in response) {
    final DateTime date = DateTime.parse(entry['created_at'] as String)
        .toLocal()
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    final int mood = entry['mood'] as int;

    moodsByDay.putIfAbsent(date, () => []).add(mood);
  }

  final Map<DateTime, double> moodAverages = {
    for (var entry in moodsByDay.entries)
      entry.key: (entry.value.reduce((a, b) => a + b) / entry.value.length) + 1
  };

  final int numberOfLabels = dateList.length < 10 ? dateList.length : 10;
  final List<int> dateIndices = List.generate(numberOfLabels, (i) {
    return ((i * (dateList.length - 1)) / (numberOfLabels - 1)).round();
  });

  final pw.Widget chartTitle = pw.Center(
    child: pw.Container(
      child: pw.Text(
        "Average moods chart",
        style: pw.TextStyle(font: pw.Font.times(), fontSize: 30),
      ),
    ),
  );

  final List<pw.PointChartValue> chartData = dateList.asMap().entries
          .where((entry) => moodAverages.containsKey(entry.value))
          .map((entry) {
            final index = entry.key;
            final date = entry.value;
            final mood = moodAverages[date] ?? 0.0;
            return pw.PointChartValue(index.toDouble(), mood);
          }).toList();
          
  try {
    final chart = pw.Chart(
      title: chartTitle,
      left: pw.Container(
        alignment: pw.Alignment.topCenter,
        margin: const pw.EdgeInsets.only(right: 5, top: 20),
        child: pw.Transform.rotateBox(
          angle: 3.14 / 2,
          child: pw.Text('Average mood',
              style: pw.TextStyle(font: pw.Font.times(), fontSize: 20)),
        ),
      ),
      bottom: pw.Text('Note date',
          style: pw.TextStyle(font: pw.Font.times(), fontSize: 20)),
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis(
          List.generate(dateList.length, (index) => index),
          divisions: true,
          format: (index) {
            if (dateIndices.contains(index)) {
              final date = dateList[index.toInt()];
              return '${date.month}/${date.day}';
            } else {
              return '';
            }
          },
          marginStart: barWidth,
          marginEnd: barWidth,
          angle: 3.14 / 6,
        ),
        yAxis: pw.FixedAxis([0, 1, 2, 3, 4, 5], 
        divisions: true,
        ),
        
      ),
      datasets: [
        pw.BarDataSet(
          width: barWidth,
          color: PdfColors.deepOrange400,
          data: chartData,
        ),
      ],
    );

    return chart;
  } catch (e) {
    log("Chart generation error: $e");
    return null;
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
    final notesResponse = await DatabaseService.instance.fetchNotes(_startDate, _endDate);
    getCounts(notesResponse);
    sortCounts();
    final testResultsResponse = await DatabaseService.instance.fetchTestResults(_startDate, _endDate);


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
              child: pw.Column(children: [
              pw.Text(
                'Note report',
                style: pw.TextStyle(
                  font: pw.Font.timesBold(),
                  fontSize: 50,
                )),
              pw.Text(
                'Date generated: ${DateTime.now().toLocal().toString().substring(0, 16)}',
                style: pw.TextStyle(
                  font: pw.Font.times(),
                  fontSize: 15,
                ),
              )
              ])),

          pw.Text(
            'Notes filled: $_noteCount\n',
            style: pw.TextStyle(font: pw.Font.times(), fontSize: 30),
          ),

          pw.SizedBox(
              child: _moodBarChart(notesResponse),
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

      String? selectedPath = await FilePicker.platform.getDirectoryPath(dialogTitle: "Choose Save Location");

      if (selectedPath == null) {
        return 1;
      }

      final filePath = '$selectedPath/report.pdf';
      final file = File(filePath);

      await file.writeAsBytes(fileContent, flush: true);

      return 0;
    }on PathAccessException catch(e) {
      log("Path access error: $e");
      return 2;
    }
    catch (e, stacktrace) {
      log("Error saving file: $e");
      log('$stacktrace');
      return 1;
    }
  }
}
