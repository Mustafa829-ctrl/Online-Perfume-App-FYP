import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider_dashboard_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider_orders_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider_payments_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/screens/rider_profile_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/widgets/rider_bottom_nav.dart';
import 'package:online_perfume_app_fyp/views/rider/widgets/rider_drawer.dart';
import '../../models/rider_model.dart';

class RiderHomeScreen extends StatefulWidget {
  final RiderModel rider;
  const RiderHomeScreen({super.key, required this.rider});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  // ✅ Titles for each tab
  final List<String> _titles = [
    'Dashboard',
    'My Orders',
    'Payments',
    'My Profile',
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fixed: use widget.rider directly — no Provider
    final rider = widget.rider;

    // ✅ Fixed: screens moved to build() so widget.rider is accessible
    final List<Widget> screens = [
      RiderDashboardScreen(rider: rider),
      RiderOrdersScreen(rider: rider),
      RiderPaymentsScreen(rider: rider),
      RiderProfileScreen(rider: rider),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      // ── App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu, color: Color(0xff5E1D04)),
          ),
        ),
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: Navigate to notifications
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_outlined,
                  color: Color(0xff5E1D04)),
            ),
          ),
        ],
      ),

      // ── Drawer
      drawer: RiderDrawer(rider: rider),

      // ── Body
      body: screens[_currentIndex],

      // ── Bottom Nav
      bottomNavigationBar: RiderBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
