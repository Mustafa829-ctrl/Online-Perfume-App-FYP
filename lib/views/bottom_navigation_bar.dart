import 'package:flutter/material.dart';
import 'package:online_perfume_app_fyp/views/onboarding.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer_homescreen.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const _activeColor = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFDDA0A8),
              Color(0xFFEFC5C9),
              Color(0xFFFFE0E4),
              Color(0xFFEFC5C9),
              Color(0xFFDDA0A8),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
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
                label: "Cart"),
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
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isActive) return;

        Widget targetScreen;
        switch (index) {
          case 0:
            targetScreen = const BuyerHomescreen();
            break;
          // case 1:
          //   targetScreen = const ExploreScreen();
          //   break;
          // case 2:
          //   targetScreen = const CartScreen();
          //   break;
          // case 3:
          //   targetScreen = const ProfileScreen();
          //   break;
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
          color: isActive ? Colors.white.withOpacity(0.30) : Colors.transparent,
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
