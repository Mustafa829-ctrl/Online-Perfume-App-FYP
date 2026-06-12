import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_analytics_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_orders_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_products_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_add_category.dart';
import 'package:online_perfume_app_fyp/views/seller/widgets/seller_bottom_nav.dart';
import 'package:online_perfume_app_fyp/views/seller/widgets/seller_drawer.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_dashboard_screen.dart';
import '../../models/seller_model.dart';

class SellerHomeScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerHomeScreen({super.key, required this.seller});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  // Default tab is Products (index 1)
  int _currentIndex = 1;

  // Title for each tab
  final List<String> _titles = [
    'Dashboard',
    'My Products',
    'Orders',
    'Analytics',
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final seller = widget.seller;

    final List<Widget> screens = [
      SellerDashboardScreen(seller: seller),
      SellerProductsScreen(seller: seller),
      SellerOrdersScreen(seller: seller),
      SellerAnalyticsScreen(seller: seller),
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
          // ── Add Category button — only visible on Products tab
          if (_currentIndex == 1)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SellerAddCategoryScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Notifications button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to notifications screen
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
      drawer: SellerDrawer(seller: seller),

      // ── Body
      body: screens[_currentIndex],

      // ── Bottom Nav
      bottomNavigationBar: SellerBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}