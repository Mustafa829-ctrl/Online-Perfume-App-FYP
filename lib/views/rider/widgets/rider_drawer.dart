import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/rider_model.dart';
import '../../../services/rider_auth_service.dart';
import '../auth/rider_login_screen.dart';
import '../auth/rider_change_password_screen.dart';

class RiderDrawer extends StatelessWidget {
  final RiderModel rider;
  const RiderDrawer({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    //  Fixed: use rider parameter directly — no Provider
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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xffD08C4A),
                  child: Text(
                    rider.name != null && rider.name!.isNotEmpty
                        ? rider.name![0].toUpperCase()
                        : 'R',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(rider.name ?? 'Rider',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  '${rider.vehicleModel ?? ''} • ${rider.vehicleNumber ?? ''}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xffD08C4A),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(rider.email ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white60)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rider.status == 'active'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rider.status == 'active' ? ' Active' : ' Inactive',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: rider.status == 'active'
                          ? const Color(0xff66BB6A)
                          : const Color(0xffEF5350),
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
                  // Change Password
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.pop(context);
                      // navigate to change password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiderChangePasswordScreen(),
                        ),
                      );
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text('Online Perfume App v1.0',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey.shade400)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await RiderAuthServices().logoutRider();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RiderLoginScreen()),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
