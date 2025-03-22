import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodify/src/components/Menu.dart';
import 'package:moodify/src/screens/AuthPage.dart';
import 'package:moodify/src/screens/EmailVerificationPage.dart';
import 'package:moodify/src/services/AuthWrapper.dart';
import 'package:moodify/src/services/UserService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uni_links/uni_links.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2YW9iaXFiZHdvZnFsbnZyZ2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNjMzOTAsImV4cCI6MjA1MTkzOTM5MH0.n2bnkip1mPwT62wSRVGdWLg0BNe3dOYTzeL7H4AmllE",
    url: "https://ivaobiqbdwofqlnvrgkt.supabase.co"
  );
  await dotenv.load(fileName: ".env");
  //await UserService.instance.getOrGenerateUserId();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _sub;

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'login-callback') {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(uri: uri),
        ),
      );
    } else {
      debugPrint("Unknown deep link: $uri");
    }
  }

  @override
  void initState() {
    super.initState();
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        debugPrint("Received deep link: $uri");
        _handleDeepLink(uri);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Moodify',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: AuthWrapper(authenticatedChild: Menu()),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          default:
            return MaterialPageRoute(
              builder: (context) => AuthWrapper(authenticatedChild: Menu()));
        }
      },
    );
  }
}

/*lass MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: AuthPage()//Menu()
    );
  }
}*/