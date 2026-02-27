import 'package:flutter/material.dart';
import 'dart:async';

import '../onboarding.dart';

class SplashScreen3 extends StatefulWidget {
  const SplashScreen3({super.key});

  @override
  State<SplashScreen3> createState() => _SplashScreen3State();
}

class _SplashScreen3State extends State<SplashScreen3> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xffEFB4B9),
                const Color(0xffDDD6D6),
              ],)
        ),
        child: Center(
          child: ClipOval(
            child: Image.asset("assets/images/logo1.png",
              width: 220,
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
