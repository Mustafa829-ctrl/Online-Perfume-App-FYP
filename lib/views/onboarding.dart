import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFB4B9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff5E1D04),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              const SizedBox(height: 30),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/perfume-6.png',
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 40),

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
              SizedBox(height: 30),

              Text(
                'Find your Fragrances tailored just for you with personalized recommendations',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight:FontWeight.w500 ,
                    color: Color(0xff5E1D04)
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Simple dots indicator (for page 1 of onboarding)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: true),
                  _buildDot(isActive: false),
                  _buildDot(isActive: false),
                ],
              ),
              const SizedBox(height: 30),

              // Bottom navigation placeholder (can move to persistent later)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true),
                  _NavItem(icon: Icons.search_rounded, label: 'Explore'),
                  _NavItem(icon: Icons.shopping_cart_rounded, label: 'Cart'),
                  _NavItem(icon: Icons.person_rounded, label: 'Profile'),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xff5E1D04) : Color(0xff908A91),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFFFF6B81) : Colors.grey.shade600,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFFFF6B81) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
