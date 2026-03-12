import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/recommendation.dart';


class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {

  bool _isLoading = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Shimmer animation controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

     //After 5 seconds: stop loader & navigate
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Recommendation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // ── Shimmer box
  Widget _shimmerBox({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFDDA0A8),
                Color(0xFFEFC5C9),
                Color(0xFFFFE0E4),
                Color(0xFFEFC5C9),
                Color(0xFFDDA0A8),
              ],
              stops: [
                0.0,
                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                _shimmerController.value.clamp(0.0, 1.0),
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFB4B9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'Onboarding',
          style: TextStyle(
              color: Color(0xff000000),
              fontSize: 24,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/perfume-6.png',
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Discover Your Perfect Scent',
                style: GoogleFonts.purplePurse(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff5E1D04),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Find your Fragrances tailored just for you with personalized recommendations',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff5E1D04)),
                 textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ── Skeleton Loader
              if (_isLoading)
                Column(
                  children: [
                    _shimmerBox(width: 180, height: 10),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 120, height: 10),
                  ],
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}