import 'package:flutter/material.dart';
import 'package:moodify/src/components/Menu.dart';
import 'package:moodify/src/services/AuthWrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AuthForm.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignUp = false;

  Future<void> signIn(String email, String password, Function(Result) completion) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        completion(Result.success());
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthWrapper(authenticatedChild: Menu())),
          (route) => false,
        );
      } else {
        completion(Result.failure(Exception('Sign in failed')));
      }
    } catch (error) {
      completion(Result.failure(error));
    }
  }

  Future<void> signUp(String email, String password, Function(Result) completion) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
      if (response.user != null) {
        completion(Result.success());
      } else {
        completion(Result.failure(Exception('Sign up failed')));
      }
    } catch (error) {
      completion(Result.failure(error));
    }
  }

  Future<void> signInWithApple() async {
    try {
      /*await Supabase.instance.client.auth.signInWithOAuth(
        Provider.apple,
      );*/
    } catch (error) {
      debugPrint("Apple Sign In error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(
        title: isSignUp ? "Create an Account" : "Welcome Back!",
        buttonTitle: isSignUp ? "Sign Up" : "Sign In",
        switchText: isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up",
        isSignUp: isSignUp,
        action: (email, password, completion) async {
          if (isSignUp) {
            await signUp(email, password, completion);
          } else {
            await signIn(email, password, completion);
          }
        },
        switchAction: () {
          setState(() {
            isSignUp = !isSignUp;
          });
        },
        appleAction: signInWithApple,
      ),
    );
  }
}

/// Klasa pomocnicza do przekazywania rezultatu
class Result {
  final bool isSuccess;
  final dynamic error;
  Result(this.isSuccess, this.error);

  factory Result.success() => Result(true, null);
  factory Result.failure(dynamic error) => Result(false, error);
}
