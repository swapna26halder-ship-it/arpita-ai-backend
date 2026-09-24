

import 'dart:async';

import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff111111),
              Color(0xff1f1f1f),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.smart_toy_rounded,
              size: 120,
              color: Color(0xffFFD700),
            ),

            SizedBox(height: 25),

            Text(
              "Arpita AI",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Your Personal AI Assistant",
              style: TextStyle(
                fontSize: 17,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 50),

            CircularProgressIndicator(
              color: Color(0xffFFD700),
            ),

          ],
        ),
      ),
    );
  }
}
