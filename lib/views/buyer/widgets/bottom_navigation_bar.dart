import 'package:flutter/material.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/buyer/cart_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/wishlist_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/profile_screen.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';

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
  static const _activeColor = Color(0xFFFF5722);

  @override
  void initState() {
    super.initState();
    CartService.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = CartService.instance.totalItemCount;
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0,
                icon: Icons.home_rounded,
                activeIcon: Icons.home_outlined,
                label: "Home"),
            _buildNavItem(context, 1,
                icon: Icons.favorite,
                activeIcon: Icons.favorite_border,
                label: "Wishlist"),
            _buildNavItem(context, 2,
                icon: Icons.shopping_bag_rounded,
                activeIcon: Icons.shopping_bag_outlined,
                label: "Cart",
                badgeCount: cartCount),
            _buildNavItem(context, 3,
                assetPath: "assets/images/Profile_photo.jpg",
                label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index, {
    IconData? icon,
    IconData? activeIcon,
    String? assetPath,
    required String label,
    int badgeCount = 0,
  }) {
    final bool isActive = widget.currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isActive) return;

        Widget targetScreen;
        switch (index) {
          case 0:
            targetScreen = const BuyerHomescreen();
            break;
          case 2:
            targetScreen = const CartScreen();
            break;
          case 1:
            targetScreen = const WishlistScreen();
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
            pageBuilder: (context, animation1, animation2) => targetScreen,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon OR asset image ──────────────────
            if (assetPath != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? _activeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      color: isActive ? _activeColor : const Color(0xFF5E1D04),
                      size: 24,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5E1D04),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Color(0xffF6B55E),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 4),

            // ── Label always shows under both icon and image ──
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? _activeColor : const Color(0xFF5E1D04),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
