import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'UserService.dart';
import 'MentalService.dart';
import '../utils/Pair.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:deepcopy/deepcopy.dart';

double abs(double number)
{
  if (number>=0) {
    return number;
  } else {
    return -number;
  }
}
class CrisisPredictionService
{
  CrisisPredictionService._privateConstructor();

  static final CrisisPredictionService _instance = CrisisPredictionService._privateConstructor();

  static CrisisPredictionService get instance => _instance;

  final SupabaseClient supabase = UserService.instance.supabase;
  
  Future<List<Pair<String, double>>> calculateDailyRisks(String user_uuid) async
  {
    List<Pair<DateTime, List<double>>> moods = await fetchMoods(user_uuid);
    List<Pair<DateTime, List<double>>> points = await fetchPoints(user_uuid);
    List<dynamic> gathered_moods_points = connect(moods, points);
    List<Pair<DateTime, double>> average_moods_points = calculate_averages_scores(gathered_moods_points);
    List<Pair<DateTime, List<double>>> scores = await fetchScores(user_uuid);
    scores = normaliseScores(scores);
    List<String> embedding_headers = await loadEmbeddingHeaders();
    List<List<Pair<DateTime, double>>> average_scores_for_headers = calculateAverageScoresForHeaders(scores, average_moods_points, embedding_headers.length);
    return calculateRisksForHeaders(average_scores_for_headers, embedding_headers);
  }
  Future<List<Pair<String, double>>> dailyRisksPercents(String user_uuid) async
  {
    List<Pair<String, double>> transformedRisks = await calculateDailyRisks(user_uuid);
    for (int i=0; i<transformedRisks.length; i++)
    {
      transformedRisks[i].setSecond(transformedRisks[i].getSecond() * 100); 
    }
    
    return transformedRisks;
  }
  List<Pair<DateTime, double>> calculate_averages_scores(List<dynamic> list)
  {
    List<Pair<DateTime, double>> average_scores = [];
    for(Pair<DateTime, List<double>> day in list)
    {
      double sum = 0;
      for (double value in day.second)
      {
        sum+=value;
      }
      average_scores.add(Pair(day.first, sum/day.second.length));
    }
    return average_scores;
  }
List<List<Pair<DateTime, double>>> calculateAverageScoresForHeaders(List<Pair<DateTime, List<double>>> scores, List<Pair<DateTime, double>> average_moods_points, int number_of_embeddings)
 {
  List<List<Pair<DateTime, double>>> result = [];
  for (int i=0; i< number_of_embeddings;i++)
  {
    List<Pair<DateTime, List<double>>> average_moods_points_list = [];
    for (Pair<DateTime, double> pair in average_moods_points)
    {
      average_moods_points_list.add(Pair(pair.first, [pair.second]));
    }
    List<Pair<DateTime, List<double>>> scores_of_embedding = [];
    for(int j=0; j < scores.length; j++)
    {
      Pair<DateTime, List<double>> pair = scores[j];
      Pair<DateTime, List<double>> score;
      if (pair.second == Null)
      {
        score = Pair(pair.first, [average_moods_points[j].second]);
      }
      else
      {
        score = Pair(pair.first, [pair.second[i]]);
      }
      scores_of_embedding.add(score);
    }
    List<dynamic> gathered_score_for_header = connect(scores_of_embedding, average_moods_points_list);
    List<Pair<DateTime, double>> average_score_for_header = calculate_averages_scores(gathered_score_for_header);
    result.add(average_score_for_header);
  }
  return result;
 }
 List<Pair<String, double>> calculateRisksForHeaders(List<List<Pair<DateTime, double>>> scores, List<String> headers)
 {
  List<Pair<String, double>> result = [];
  for (int i = 0; i< headers.length;i++)
  {
    List<double> risks = calculateRiskValues(scores[i]);
    result.add(Pair(headers[i], risks.last));
  }
  return result;
 }
Future<List<String>> loadEmbeddingHeaders() async {
  final fileContent = await rootBundle.loadString('assets/a.txt'); // Await the asynchronous operation
  final lines = fileContent.split('\n').map((line) => line.trim()).toList();
  final List<dynamic> decodedJson = jsonDecode(lines[0]); // Decode as List<dynamic>
  return decodedJson.cast<String>().toList(); // Explicitly cast to List<String>
}


List<dynamic> connect(List<Pair<DateTime, List<double>>> l1, List<Pair<DateTime, List<double>>> l2)
{
    List list1 = l1.deepcopy();
    List list2 = l2.deepcopy();
    if (list1.isEmpty)
    {
      if(list2.isEmpty)
      {
        return [];
      }
      return list2;
    }
    if (list2.isEmpty)
    {
      return list1;
    }
    List<Pair<DateTime, List<double>>> connected =[];
    int list1_index = 0;
    int list2_index = 0;
    DateTime current_datetime = DateTime(2024, 1, 1);
    if (list1[0].first.difference(list2[0].first).inDays <= 0 )
    {
      connected.add(list1[0]);
      current_datetime = list1[0].first;
      list1_index++;
    }
    else
    {
      connected.add(list2[0]);
      current_datetime = list2[0].first;
      list2_index++;  
    }
    while(list1_index < list1.length && list2_index < list2.length)
    {
      if(list1[list1_index].first.difference(current_datetime).inDays == 0)
      {
        connected[connected.length-1].second.addAll(list1[list1_index].second);
        list1_index++;
      }
      else if(list2[list2_index].first.difference(current_datetime).inDays == 0)
      {
        connected[connected.length-1].second.addAll(list2[list2_index].second);
        list2_index++;
      }
      else if(list1[list1_index].first.difference(list2[list2_index].first).inDays < 0)
      {
        connected.add(list1[list1_index]);
        current_datetime = list1[list1_index].first;
        list1_index++;
      }
      else if(list1[list1_index].first.difference(list2[list2_index].first).inDays >= 0)
      {
        connected.add(list2[list2_index]);
        current_datetime = list2[list2_index].first;
        list2_index++;
      }
    }
    for (list1_index; list1_index < list1.length; list1_index++)
    {
      if(list1[list1_index].first.difference(current_datetime).inDays == 0)
      {
        connected[connected.length-1].second.addAll(list1[list1_index].second);
      }
      else
      {
        connected.add(list1[list1_index]);
        current_datetime = list1[list1_index].first;
      }
    }
    for (list2_index; list2_index < list2.length; list2_index++)
    {
      if(list2[list2_index].first.difference(current_datetime).inDays == 0)
      {
        connected[connected.length-1].second.addAll(list2[list2_index].second);
      }
      else
      {
        connected.add(list2[list2_index]);
        current_datetime = list2[list2_index].first;
      }
    }
    return connected;
}
Future<List<Pair<DateTime, List<double>>>> fetchMoods(String user_uuid) async {
  try {
    final response = await supabase.from('notes').select('*').eq('user_id', user_uuid);
    print("success");
    final List<Pair<DateTime, List<double>>> moodList = response.map((element) {
      final DateTime createdAt = DateTime.parse(element['created_at'] as String);
      final double mood = (element['mood'] as int).toDouble() / 4;
      return Pair(createdAt, [mood]);
    }).toList();
    moodList.sort((a, b) => a.first.compareTo(b.first));

    return moodList;
  } catch (e) {
    print("Error reading activities: $e");
    return [];
  }
}
Future<List<Pair<DateTime, List<double>>>> fetchPoints(String user_uuid) async {
  try {
    final response = await supabase.from('phq-9_results').select('*').eq('user_id', user_uuid);
    print("success");
    final List<Pair<DateTime, List<double>>> moodList = response.map((element) {
      final DateTime createdAt = DateTime.parse(element['created_at'] as String);
      final double points = (element['points'] as int).toDouble() / 27;

      return Pair(createdAt, [points]);
    }).toList();
    moodList.sort((a, b) => a.first.compareTo(b.first));

    return moodList;
  } catch (e) {
    print("Error reading activities: $e");
    return [];
  }
}
Future<List<Pair<DateTime, List<double>>>> fetchScores(String user_uuid) async {
  try {
    final response = await supabase.from('notes').select('*').eq('user_id', user_uuid);
    print("success");
    final List<Pair<DateTime, List<double>>> moodList = response.map<Pair<DateTime, List<double>>>((element) {
      final DateTime createdAt = DateTime.parse(element['created_at'] as String);
      final List<double> points = (element['scores'] as List<dynamic>)
          .map((score) => score as double)
          .toList();

      return Pair(createdAt, points);
    }).toList();
    moodList.sort((a, b) => a.first.compareTo(b.first));

    return moodList;
  } catch (e) {
    print("Error reading activities: $e");
    return [];
  }
}
List<Pair<DateTime, List<double>>> normaliseScores(List<Pair<DateTime, List<double>>> scores)
{
  for (int j=0;j < scores.length;j++ )
  {
    Pair<DateTime, List<double>> score = scores[j];
    for (int i = 0; i < score.second.length; i++)
    {
      double value = score.second[i];
      score.second[i] = (max(min(0.5, value), 0.1)-0.1)*2.5;
    }
    scores[j] = score;
  }
  return scores;
}
}

List<double> calculateRiskValues(List<Pair<DateTime, double>> data,
    {int t1 = 6}) {
  int t2 = data.length;
  int time_window = t1;
  double k = 0.03 * t1.toDouble() * t1.toDouble() -
      0.85 * t1.toDouble() +
      6.5; // polynomial interpolation of few desired values, done to define
  // less parameteres, might be subject to a change
  double maxValue = 0.0;
  for (Pair pair in data) {
    if (pair.second > maxValue) {
      maxValue = pair.second;
    }
  }
  List<Pair<DateTime, double>> normalised_data = [];
  for (Pair<DateTime, double> pair in data) {
    Pair<DateTime, double> new_pair = Pair(pair.first, pair.second / maxValue);
    normalised_data.add(new_pair);
  }
  data = normalised_data;
  List<double> variabilities = calculateVariabilities(data);
  double mean_variability = calculateWeightedMean(data, variabilities, 1, t2);
  List<double> sigmaVariabilities = calculateSigmaVariabilities(
      data, variabilities, mean_variability, t1, t2, time_window);
  List<double> derivatives =
      calculateDerivativeOfSigma(data, sigmaVariabilities, t1, t2);
  double meanDerivatives = calculateWeightedMean(data, derivatives, t1 + 1, t2);
  double sigmaDerivatives =
      calculateSigma(data, derivatives, meanDerivatives, t1 + 1, t2, t1 + 1);
  List<double> normalisedDerivatives =
      normalise(derivatives, meanDerivatives, sigmaDerivatives);

  List<double> risk = [];
  for (double value in normalisedDerivatives) {
    risk.add(max(min(abs(value) / k, 1), 0));
  }
  return risk;
}

List<double> calculateVariabilities(List<Pair<DateTime, double>> data) {
  List<double> variabilities = [];
  for (int i = 0; i < data.length - 1; i++) {
    double variability = (data[i + 1].second - data[i].second) /
        (data[i + 1].first.difference(data[i].first)).inDays.toDouble();
    variabilities.add(variability);
  }
  return variabilities;
}

double calculateWeightedMean(List<Pair<DateTime, double>> dataTimestamps,
    List<double> data, int t1, int t2) {
      double weighted_sum = 0.0;
      double sum_of_weights = 0.0;
      for (int i =0; i < t2-t1; i++)
      {
        double weight = 0.0;
        if (t1+i != 0)
        {
          weight = dataTimestamps[t1+i].first.difference(dataTimestamps[t1+i-1].first).inDays.toDouble();
        }
        weighted_sum += weight*data[i];
        sum_of_weights += weight;
      }
    return weighted_sum/sum_of_weights;
}

double calculateSigma(List<Pair<DateTime, double>> dataTimestamps,
    List<double> data, double mean, int t1, int t2, int offset) {
      double weighted_sum = 0.0;
      double sum_of_weights = 0.0;
      for (int i =0; i < t2-t1; i++)
      {
        double weight = 0.0;
        if (t1+i != 0)
        {
          weight = dataTimestamps[t1+i].first.difference(dataTimestamps[t1+i-1].first).inDays.toDouble();
        }
        weighted_sum += weight*pow(data[t1+i-offset]-mean,2);
        sum_of_weights += weight;
      }
      return sqrt(weighted_sum/sum_of_weights);
}

List<double> calculateSigmaVariabilities(
    List<Pair<DateTime, double>> dataTimestamps,
    List<double> data,
    double mean,
    int t1,
    int t2,
    int t) {
      List<double> sigmaVariabilities = [];
      for (int i =t1+1; i < t2+1; i++)
      {
        sigmaVariabilities.add(calculateSigma(dataTimestamps, data, mean, i - t, i, 1));
      }
    return sigmaVariabilities;
}

List<double> calculateDerivativeOfSigma(
    List<Pair<DateTime, double>> dataTimestamps,
    List<double> data,
    int t1,
    int t2) {
      List<double> derivatives = [];
      for (int i = 0; i < t2-t1 - 1; i++)
      {
        double deltaSigma = data[i+1] - data[i];
        double deltaT = dataTimestamps[t1+i+1].first.difference(dataTimestamps[t1+i].first).inDays.toDouble();
        derivatives.add(deltaSigma/deltaT);
      }
      return derivatives;
}

List<double> normalise(List<double> data, double mean, double sigma) {
  List<double> normalisedData = [];
  for (double datum in data)
  {
    normalisedData.add((datum - mean)/ sigma);
  }
  return normalisedData;
}