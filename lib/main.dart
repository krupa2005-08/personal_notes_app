import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_notes_app/screens/home_screen.dart';

import 'models/note.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register our custom object adapter
  Hive.registerAdapter(NoteAdapter());

  // Open a box
  await Hive.openBox<Note>('notes');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Use system theme (light/dark)
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // You can customize the dark theme further
      ),
      home: HomeScreen(),
    );
  }
}
