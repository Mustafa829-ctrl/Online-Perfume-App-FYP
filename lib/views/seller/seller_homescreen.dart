import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_analytics_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_orders_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_products_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/widgets/seller_bottom_nav.dart';
import 'package:online_perfume_app_fyp/views/seller/widgets/seller_drawer.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_dashboard_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  // Default tab is Products (index 1)
  int _currentIndex = 1;

  // All 4 bottom nav screens
  final List<Widget> _screens = const [
    SellerDashboardScreen(),
    SellerProductsScreen(),
    SellerOrdersScreen(),
    SellerAnalyticsScreen(),
  ];

  // Title for each tab
  final List<String> _titles = [
    'Dashboard',
    'My Products',
    'Orders',
    'Analytics',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      // ── App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Hamburger menu — opens drawer
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(
              Icons.menu,
              color: Color(0xff5E1D04),
            ),
          ),
        ),
        // Screen title changes with tab
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        // Notification bell on right
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: Navigate to notifications screen
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.notifications_outlined,
                color: Color(0xff5E1D04),
              ),
            ),
          ),
        ],
      ),

      // ── Drawer
      drawer: const SellerDrawer(
        sellerName: 'Ali Hassan',
        sellerEmail: 'ali@perfume.com',
        shopName: 'Hassan Perfumes',
      ),

      // ── Body — switches between screens
      body: _screens[_currentIndex],

      // ── Bottom Nav
      bottomNavigationBar: SellerBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
