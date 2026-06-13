import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/user_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/profile_screen.dart';

import '../buyer auth/buyer_change_password_screen.dart';
import '../buyer auth/buyer_login_screen.dart';
import 'buyer_complaints_screen.dart';
import 'order_history_screen.dart';


class BuyerMenuBar extends StatelessWidget {
  const BuyerMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Dynamic Header
          StreamBuilder<DocumentSnapshot>(
            stream: currentUser != null
                ? FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHeaderPlaceholder();
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildHeaderPlaceholder(text: 'Profile not found');
              }
              final data = snapshot.data!.data() as Map<String, dynamic>;
              return _buildRealHeader(
                name: data['name'] ?? 'Guest',
                email: data['email'] ?? '',
                imageUrl: data['profileImageUrl'] ?? '',
              );
            },
          ),

          // ── Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BuyerHomescreen()),
                      );
                    },
                  ),
                  // orders
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order History',
                    onTap: () {
                      Navigator.pop(context);
                       Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen()));
                    },
                  ),

                  //  Complaints
                  _MenuItem(
                    icon: Icons.report_problem_outlined,
                    label: 'Complaints',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BuyerComplaintsScreen()));
                    },
                  ),

                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.grey.shade200),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ACCOUNT',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const BuyerChangePasswordScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.grey.shade200),
                  ),

                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    isLogout: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await UserService().logoutUser();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BuyerHomescreen()),
                        (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString(),
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Logout',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildRealHeader({
    required String name,
    required String email,
    required String imageUrl,
  }) {
    return Container(
      color: const Color(0xff5E1D04),
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xffD08C4A),
            backgroundImage:
            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'G',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )
                : null,
          ),
          const SizedBox(height: 10),
          Text(name,
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(email,
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder({String text = 'Loading...'}) {
    return Container(
      color: const Color(0xff5E1D04),
      height: 160,
      child: Center(
        child: Text(text,
            style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? Colors.red.shade400 : const Color(0xffD08C4A)),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isLogout ? Colors.red.shade400 : const Color(0xff5E1D04),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}