import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1C8C6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xff5E1D04)),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const ProfileHeader(
              name: "Ashraf Muhsin",
              imagePath: "assets/images/Profile_photo.jpg",
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileStatCard(value: "24", label: "ORDERS"),
                ProfileStatCard(value: "13", label: "REVIEWS"),
                ProfileStatCard(value: "48", label: "WHISHLIST"),
              ],
            ),
            const SizedBox(height: 32),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Account Settings",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            SettingsTile(
              icon: Icons.person,
              title: "Personal Information",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.book,
              title: "Scent Diary",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.payment,
              title: "Payment Method",
              onTap: () {},
            ),
            
            const SizedBox(height: 40),
            const SignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
