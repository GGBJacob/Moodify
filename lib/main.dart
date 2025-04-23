import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:moodify/src/components/Menu.dart';
import 'package:moodify/src/screens/EmailVerificationPage.dart';
import 'package:moodify/src/services/AuthWrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2YW9iaXFiZHdvZnFsbnZyZ2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNjMzOTAsImV4cCI6MjA1MTkzOTM5MH0.n2bnkip1mPwT62wSRVGdWLg0BNe3dOYTzeL7H4AmllE",
    url: "https://ivaobiqbdwofqlnvrgkt.supabase.co"
  );
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _sub;

   final List<String> imagesToCache = ['assets/very_sad.png', 'assets/sad.png', 'assets/neutral.png', 'assets/happy.png', 'assets/very_happy.png'];

  void _preloadImages() {
    for (int i = 0; i < imagesToCache.length; i++) {
      precacheImage(AssetImage(imagesToCache[i]), context);
    }
    afterPreload();
  }

  void afterPreload() async{
    await Future.delayed(const Duration(milliseconds: 1500));
    FlutterNativeSplash.remove();
  }

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

  late final AppLinks _appLinks;

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
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