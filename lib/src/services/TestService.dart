import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserService.dart';

class TestService {

  TestService._privateConstructor();

  static final TestService _instance = TestService._privateConstructor();

  static TestService get instance => _instance;

  final SupabaseClient supabase = UserService.instance.supabase;


  Future<void> saveTest (int points, List<int> selectedAnswers) async {

    final String answers = convertAnswersToBits(selectedAnswers);

    String user_id = await UserService.instance.getOrGenerateUserId();

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
}