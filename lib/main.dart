import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

import 'models/themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income Expense Calculator',
      theme: ThemeProvider.getTheme(ThemeProvider.currentTheme),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}