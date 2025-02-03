import 'package:flutter/material.dart';
import 'package:moodify/src/components/Menu.dart';
import 'package:moodify/src/services/UserService.dart';
import 'package:moodify/src/utils/themes/ThemeProvider';
import 'package:moodify/src/utils/themes/darkTheme.dart';
import 'package:moodify/src/utils/themes/lightTheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2YW9iaXFiZHdvZnFsbnZyZ2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNjMzOTAsImV4cCI6MjA1MTkzOTM5MH0.n2bnkip1mPwT62wSRVGdWLg0BNe3dOYTzeL7H4AmllE",
    url: "https://ivaobiqbdwofqlnvrgkt.supabase.co"
  );
  await dotenv.load(fileName: ".env");
  await UserService.instance.getOrGenerateUserId();
  runApp(
   ChangeNotifierProvider<ThemeProvider>( 
      create: (context) => ThemeProvider(), 
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodify',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Menu()
    );
  }
}