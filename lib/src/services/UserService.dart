import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  String? _userKey = null;

  String getUserId(){
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      return user.id;
    }
    throw Exception('User not authenticated');
  }
  
  Future<String> getUserKey() async{
    if (_userKey != null) {
      return _userKey!;
    }
    var response = await Supabase.instance.client.
    from('user_keys')
    .select('key')
    .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

    _userKey = response[0]['key'];
    return _userKey!;
  }
}