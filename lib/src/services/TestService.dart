import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class TestService {

  TestService._privateConstructor();

  static final TestService _instance = TestService._privateConstructor();

  static TestService get instance => _instance;

  final SupabaseClient supabase = Supabase.instance.client;


  Future<void> saveTest (int points, List<int> selectedAnswers) async {

    final String answers = convertAnswersToBits(selectedAnswers);

    String user_id = Supabase.instance.client.auth.currentUser?.id ?? (throw Exception("User not authenticated"));

    // Insert to phq-9 test table
    final response = await supabase
      .from('phq-9_results')
      .insert([
        { 'user_id': user_id, 'points': points, 'answers': answers},
      ])
      .select();

    int testId = response[0]['id'];
    log("Added test result $testId!");
  }

  String convertAnswersToBits(List<int> selectedAnswers)
  {
      String bitMask = '';
      for (var answer in selectedAnswers)
      {
        bitMask += answer.toRadixString(2).padLeft(2, '0');
      }
      return bitMask;
  }

  List<int> convertBitsToAnswers(String bits) {
    List<int> result = [];

    for (int i = 0; i < bits.length; i += 2) {
      String pair = bits.substring(i, i + 2);

      result.add(int.parse(pair, radix: 2));
    }

    return result;
}
}