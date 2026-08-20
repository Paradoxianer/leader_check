import 'package:flutter/material.dart';

import 'screens/start_screen.dart';
import 'theme.dart';

void main() {
  runApp(const LeaderCheckApp());
}

class LeaderCheckApp extends StatelessWidget {
  const LeaderCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitertyp-Check',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const StartScreen(),
    );
  }
}
