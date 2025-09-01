import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ptunes/home_page.dart';
import 'package:ptunes/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 sec baad next screen pe le jane k liye
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // screen width ke hisaab se logo ka size
    double logoSize = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.white, // Background white kar diya
      body: Center(
        child: Image.asset(
          "assets/charulogo.png", // apna logo path
          width: 350,
          height: 350,
        ),
      ),
    );
  }
}
