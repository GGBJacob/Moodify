import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String getUserId(){
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      return user.id;
    }
    throw Exception('User not authenticated');
  }
}