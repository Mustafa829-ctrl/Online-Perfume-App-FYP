import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/cart_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/profile_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/wishlist_screen.dart';
import '../buyer auth/buyer_login_screen.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  // ── Check if user is logged in
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ── Get cart count stream directly from Firestore
  // Returns 0 if not logged in
  Stream<int> get _cartCountStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── Show login prompt dialog
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline,
                color: Color(0xffD08C4A), size: 24),
            const SizedBox(width: 8),
            Text(
              'Login Required',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Please login or create an account to access this feature.',
          style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BuyerLoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5E1D04),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Login',
                style: GoogleFonts.poppins(
                    color: const Color(0xffD08C4A),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (widget.currentIndex == index) return;

    // Guard cart, wishlist, profile — require login
    if (!_isLoggedIn && index != 0) {
      _showLoginPrompt(context);
      return;
    }

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const BuyerHomescreen();
        break;
      case 1:
        targetScreen = const WishlistScreen();
        break;
      case 2:
        targetScreen = const CartScreen();
        break;
      case 3:
        targetScreen = const ProfileScreen();
        break;
      default:
        targetScreen = const BuyerHomescreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _cartCountStream,
      initialData: 0,
      builder: (context, snapshot) {
        final int cartCount = snapshot.data ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: (index) => _onNavTap(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xffD08C4A),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Wishlist',
              ),

              // Cart with live badge from Firestore stream
              BottomNavigationBarItem(
                icon: _CartIcon(
                  cartCount: cartCount,
                  isLoggedIn: _isLoggedIn,
                  isActive: false,
                ),
                activeIcon: _CartIcon(
                  cartCount: cartCount,
                  isLoggedIn: _isLoggedIn,
                  isActive: true,
                ),
                label: 'Cart',
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Cart Icon with badge
class _CartIcon extends StatelessWidget {
  final int cartCount;
  final bool isLoggedIn;
  final bool isActive;

  const _CartIcon({
    required this.cartCount,
    required this.isLoggedIn,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive
            ? Icons.shopping_bag_rounded
            : Icons.shopping_bag_outlined),
        if (cartCount > 0 && isLoggedIn)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xff5E1D04),
                shape: BoxShape.circle,
              ),
              constraints:
              const BoxConstraints(minWidth: 17, minHeight: 17),
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(
                  color: Color(0xffD08C4A),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}