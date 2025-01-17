import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  
  UserService._privateConstructor() {
    _initialize(); // Wywołujemy inicjalizację
  }
  
  static final UserService _instance = UserService._privateConstructor();

  static UserService get instance => _instance;

  final SupabaseClient supabase  = Supabase.instance.client;

  late String user_id;

  void _initialize() async {
    user_id = await getOrGenerateUserId();
  }

  Future<String> getOrGenerateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? storedUserId = prefs.getString('user_id');
    
    if (storedUserId == null) {
      // If no user id was found, generate one
      var uuid = Uuid();
      storedUserId = uuid.v4();
      await prefs.setString('user_id', storedUserId); // Save UUID in memory
    }

    // Rerurn and save UUID
    user_id = storedUserId;
    return storedUserId;
  }

  /*  Failed attempt at signing in without credentials, for automatic user.id assignment
  Future<void> signInOrRestoreAnonymousUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('anon_user_id');

    if (storedUserId == null)
    {
      supabase.auth.signInAnonymously();
      final session = supabase.auth.currentSession!;

      await prefs.setString('anon_user_id', supabase.auth.currentUser!.id);
      await prefs.setString('access_token', session.accessToken);
      await prefs.setString('refresh_token', session.refreshToken!);
      print("Signed in anonymously!");
      return;
    }

    var refresh_token = await prefs.get('refresh_token');
    if (refresh_token != null)
    {
      var response = supabase.auth.recoverSession(refresh_token.toString());
      print("Response of recovery: " + response.toString());
    }

  } */
}