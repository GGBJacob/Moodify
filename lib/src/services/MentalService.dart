import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

class MentalService {
  static final MentalService _instance = MentalService._internal();

  factory MentalService() => _instance;

  MentalService._internal();

  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<Map<String, List<double>>> loadEmbeddingsAsJson() async {
    final fileContent =
        await rootBundle.loadString('assets/a.txt');

    final lines = fileContent.split('\n').map((line) => line.trim()).toList();
    final headers = jsonDecode(lines[0]) as List<dynamic>;

    final dataVectors =
        lines.skip(1).map((line) => jsonDecode(line) as List<dynamic>).toList();

    if (headers.length != dataVectors.length) {
      throw Exception(
          'Number of headers does not match the number of embeddings.');
    }

    return Map.fromIterables(
      headers.map((header) => header.toString()),
      dataVectors.map((values) => values.cast<double>()),
    );
  }

  Future<List<double>> collectTextEmbedding(String text) async {
    final request = await HttpClient()
        .postUrl(Uri.parse('https://api.openai.com/v1/embeddings'));
    request.headers.contentType = ContentType.json;
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.write(jsonEncode({
      "input": text,
      "model": "text-embedding-3-small",
    }));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonResponse = jsonDecode(responseBody);
    return (jsonResponse['data'][0]['embedding'] as List<dynamic>)
        .cast<double>();
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<List<double>> assess(String text) async {
    final textEmbedding = await collectTextEmbedding(text);
    final embeddings =
        await loadEmbeddingsAsJson();
    final List<double> similarities = [];

    embeddings.forEach((category, embedding) {
      final similarity = cosineSimilarity(textEmbedding, embedding);
      similarities.add(similarity);
    });

    return similarities;
  }
}
