import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CommunionTableTalksApp());
}

class CommunionTableTalksApp extends StatelessWidget {
  const CommunionTableTalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communion Table Talks',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
