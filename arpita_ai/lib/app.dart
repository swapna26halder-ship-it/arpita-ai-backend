
import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'app_theme.dart';

class ArpitaAIApp extends StatelessWidget {
  const ArpitaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arpita AI',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}
