import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:moodify/src/components/Menu.dart';
import 'package:moodify/src/services/UserService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2YW9iaXFiZHdvZnFsbnZyZ2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNjMzOTAsImV4cCI6MjA1MTkzOTM5MH0.n2bnkip1mPwT62wSRVGdWLg0BNe3dOYTzeL7H4AmllE",
    url: "https://ivaobiqbdwofqlnvrgkt.supabase.co"
  );
  await dotenv.load(fileName: ".env");
  await UserService.instance.getOrGenerateUserId();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: Menu()
    );
  }
}