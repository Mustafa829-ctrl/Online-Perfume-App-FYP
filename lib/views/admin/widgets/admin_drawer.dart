import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/admin_auth_service.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/user_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/order_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/seller_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/rider_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/complaint_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/admin_profile_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/add_user.dart';
import 'package:online_perfume_app_fyp/views/admin/auth/admin_change_password_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/auth/admin_login_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/admin_homescreen.dart';
import 'package:online_perfume_app_fyp/models/admin_model.dart';

class AdminDrawer extends StatelessWidget {
  final AdminModel admin;

  const AdminDrawer({
    super.key,
    required this.admin,
  });

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AdminAuthService().logoutAdmin();
              } catch (e) {
                // ignore error — still navigate to login
              }
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD08C4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: const Color(0xff5E1D04),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = admin.name ?? 'Admin';
    final String email = admin.email ?? '';

    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: SafeArea(
        child: Column(
          children: [
            // ── Admin Profile Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3CD),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xffD08C4A),
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: () => _navigate(
                        context, AdminHomeScreen(admin: admin)),
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'User Management',
                    onTap: () => _navigate(
                        context, const AdminUserListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Orders',
                    onTap: () => _navigate(
                        context, const AdminOrderListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.store_outlined,
                    label: 'Seller Details',
                    onTap: () => _navigate(
                        context, const AdminSellerListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Rider Details',
                    onTap: () => _navigate(
                        context, const AdminRiderListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.report_outlined,
                    label: 'Complaints Section',
                    onTap: () => _navigate(
                        context, const AdminComplaintListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.person_add_outlined,
                    label: 'Add User',
                    onTap: () => _navigate(
                        context, const AddUserScreen()),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.grey.shade200),
                  ),

                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    onTap: () => _navigate(
                        context, AdminProfileScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => _navigate(
                        context, const AdminChangePasswordScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    textColor: const Color(0xFF721C24),
                    iconColor: const Color(0xFF721C24),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xffD08C4A),
        size: 22,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xff5E1D04),
        ),
      ),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: const Color(0xFFFFF3CD),
    );
  }
}
