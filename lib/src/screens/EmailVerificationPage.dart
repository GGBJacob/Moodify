import 'package:flutter/material.dart';
import 'package:moodify/src/services/AuthWrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:moodify/src/components/Menu.dart'; // Dodaj import Menu

class EmailVerificationPage extends StatefulWidget {
  final Uri? uri;
  const EmailVerificationPage({Key? key, this.uri}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String? _message;
  StreamSubscription? _sub;
  bool _verificationSuccess = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _initVerification();
  }

  void _initVerification() async {
    if (widget.uri != null) {
      await _processUri(widget.uri!);
    } else {
      await _handleInitialUri();
    }
    
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        await _processUri(uri);
      }
    }, onError: (error) {
      setState(() {
        _message = "Error reading URI: $error";
      });
    });
  }

  Future<void> _handleInitialUri() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        await _processUri(initialUri);
      } else {
        setState(() {
          _message = "Error: no initial URI";
        });
      }
    } catch (error) {
      setState(() {
        _message = "Error reading URI: $error";
      });
    }
  }

  Future<void> _processUri(Uri uri) async {
    // Tutaj dodaj faktyczną logikę weryfikacji
    // Przykład: await Supabase.instance.client.auth.verifyEmailOTP(token: uri.toString());
    
    final session = Supabase.instance.client.auth.currentSession;
    _user = session?.user;

    setState(() {
      _message = "Email verification successful!";
    });
  }

  void _handleBackButton() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AuthWrapper(authenticatedChild: Menu())),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackButton,
        ),
      ),
      body: Center(
        child: _message != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _message!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (_verificationSuccess && _user != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => Menu()),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}