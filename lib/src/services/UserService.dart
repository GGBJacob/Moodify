import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodify/src/screens/AuthPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Future<String> getOrGenerateUserId(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      return user.id;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthPage()),
        );
      });
      throw Exception('User not authenticated');
    }
  }
}