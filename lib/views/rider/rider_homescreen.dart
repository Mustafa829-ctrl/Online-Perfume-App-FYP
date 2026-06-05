import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider-orders-screen.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider_profile_screen.dart';
import 'package:provider/provider.dart';

import '../../provider/rider-provider.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _RiderDashboard(),
    RiderOrdersScreen(),
    RiderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff5E1D04),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle:
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_outlined),
              activeIcon: Icon(Icons.delivery_dining_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments_rounded),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderDashboard extends StatelessWidget {
  const _RiderDashboard();

  @override
  Widget build(BuildContext context) {
    final rider = context.watch<RiderProvider>().rider;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning,',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade500)),
                      Text(
                        rider?.name ?? 'Rider',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xffD08C4A), size: 22),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xff5E1D04),
                  child: Text(
                    (rider?.name ?? 'R')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffD08C4A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff5E1D04),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle,
                      color: Color(0xff4CAF50), size: 10),
                  const SizedBox(width: 8),
                  Text('You are Online',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rider ID',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white54)),
                      Text(rider?.riderId ?? '—',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffD08C4A))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            Text('Today\'s Overview',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard(
                  label: 'Assigned',
                  value: '0',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFFFFF3CD),
                  iconColor: const Color(0xffD08C4A),
                ),
                _StatCard(
                  label: 'Picked Up',
                  value: '0',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFFE8F5E9),
                  iconColor: Colors.green.shade600,
                ),
                _StatCard(
                  label: 'Delivered',
                  value: rider?.successfulDeliveries.toString() ?? '0',
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue.shade600,
                ),
                _StatCard(
                  label: 'Total Trips',
                  value: rider?.totalDeliveries.toString() ?? '0',
                  icon: Icons.route_outlined,
                  color: const Color(0xFFF3E5F5),
                  iconColor: Colors.purple.shade400,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick actions
            Text('Quick Actions',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionBtn(
                    label: 'View Orders',
                    icon: Icons.delivery_dining_rounded,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionBtn(
                    label: 'Payments',
                    icon: Icons.payments_rounded,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionBtn(
                    label: 'My Profile',
                    icon: Icons.person_rounded,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionBtn(
                    label: 'Change Password',
                    icon: Icons.lock_outline_rounded,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04))),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionBtn(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xffD08C4A), size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff5E1D04))),
          ],
        ),
      ),
    );
  }
}