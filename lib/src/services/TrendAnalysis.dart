import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import '../utils/Pair.dart';


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
    risk.add(max(min(value / k, 1), 0));
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
      for (int i =0; i < t2-t1; i++)
      {
        double deltaSigma = data[i+1] - data[i];
        double deltaT = dataTimestamps[t1+i+1].first.difference(dataTimestamps[t1+i].first).inDays.toDouble();
        derivatives.add(deltaSigma/deltaT);
      }
      return derivatives;
}

List<double> normalise(List<double> data, double mean, double sigma) {
  List<double> normalisedData = []
  for (double datum in data)
  {
    normalisedData.add((datum - mean)/ sigma);
  }
  return normalisedData;
}
