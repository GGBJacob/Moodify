import 'package:flutter/material.dart';
import 'package:moodify/src/screens/AuthPage.dart';
import 'package:moodify/src/screens/EmailVerificationPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedChild;
  final bool verifyEmail;

  const AuthWrapper({
    super.key,
    required this.authenticatedChild,
    this.verifyEmail = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        final user = session?.user;

        if (user != null) {
          if (verifyEmail && user.emailConfirmedAt == null) {
            return EmailVerificationPage();
          }
          return authenticatedChild;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AuthPage()),
            (route) => false,
          );
        });
        
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}