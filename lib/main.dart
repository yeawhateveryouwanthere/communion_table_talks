import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell_screen.dart';
import 'data/seed_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Seed Firestore with sample data (only runs once if empty)
  await seedFirestore();
  runApp(const CommunionTableTalksApp());
}

class CommunionTableTalksApp extends StatelessWidget {
  const CommunionTableTalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communion Table Talks',
      theme: AppTheme.lightTheme,
      home: const MainShellScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
