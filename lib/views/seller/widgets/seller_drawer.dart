import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/seller_model.dart';
import '../../../services/seller_auth_service.dart';
import '../screens/seller_complaints_screen.dart';
import '../seller%20auth/seller_login_screen.dart';
import '../seller%20auth/seller_change_password_screen.dart';
import '../screens/seller_expenses_screen.dart';
import '../screens/seller_payments_screen.dart';
import '../screens/seller_profile_screen.dart';
import '../screens/seller_ratings_screen.dart';
import '../screens/seller_riders_screen.dart';
import '../screens/seller_threshold_screen.dart';

class SellerDrawer extends StatelessWidget {
  //  Accept full SellerModel instead of 3 separate strings
  final SellerModel seller;

  const SellerDrawer({
    super.key,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
            decoration: const BoxDecoration(color: Color(0xff5E1D04)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xffD08C4A),
                  child: Text(
                    seller.name != null && seller.name!.isNotEmpty
                        ? seller.name![0].toUpperCase()
                        : 'S',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),

                // Real seller name from SellerModel
                Text(
                  seller.name ?? 'Seller',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),

                //  Real business name from SellerModel
                Text(
                  seller.businessName ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xffD08C4A),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),

                //  Real email from SellerModel
                Text(
                  seller.email ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.white60),
                ),
                const SizedBox(height: 8),

                //  Verification status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: seller.isVerified == true
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    seller.isVerified == true
                        ? ' Verified'
                        : ' Pending Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: seller.isVerified == true
                          ? const Color(0xff66BB6A)
                          : const Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Rider Management
                  _DrawerItem(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Rider Management',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerRidersScreen(seller: seller),
                      ));
                    },
                  ),

                  // Stock Threshold
                  _DrawerItem(
                    icon: Icons.warning_amber_outlined,
                    label: 'Stock Threshold',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerThresholdScreen(seller: seller),
                      ));
                    },
                  ),

                  // Complaints
                  _DrawerItem(
                    icon: Icons.report_problem_outlined,
                    label: 'Complaints',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerComplaintsScreen(seller: seller),
                      ));
                    },
                  ),

                  // Ratings & Reviews
                  _DrawerItem(
                    icon: Icons.star_outline,
                    label: 'Ratings & Reviews',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerRatingsScreen(seller: seller),
                      ));
                    },
                  ),

                  // Expenses
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Expenses',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerExpensesScreen(seller: seller),
                      ));
                    },
                  ),

                  // Payments
                  _DrawerItem(
                    icon: Icons.payments_outlined,
                    label: 'Payments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerPaymentsScreen(seller: seller),
                      ));
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.grey.shade200),
                  ),

                  // Profile
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellerProfileScreen(seller: seller),
                      ));
                    },
                  ),

                  //  Change Password — navigates to real screen
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SellerChangePasswordScreen(),
                      ));
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.grey.shade200),
                  ),

                  // Logout
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    textColor: Colors.red.shade400,
                    iconColor: Colors.red.shade400,
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

          // ── Footer
         // Padding(
           // padding: const EdgeInsets.only(bottom: 20),
           // child: Text('Online Perfume App v1.0',
           //     style: GoogleFonts.poppins(
            //        fontSize: 11, color: Colors.grey.shade400)),
          // ),
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
            style: GoogleFonts.poppins(
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
            //  Real Firebase logout
            onPressed: () async {
              try {
                Navigator.pop(context);
                await SellerAuthServices().logoutSeller();

                if (context.mounted) {
                  // Navigate to login and remove all routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SellerLoginScreen()),
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
}

// ── Reusable Drawer Item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon,
          color: iconColor ?? const Color(0xffD08C4A), size: 22),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor ?? const Color(0xff5E1D04))),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
