import 'package:flutter/material.dart';


class MenuBarScreen extends StatelessWidget {
  const MenuBarScreen({super.key});

  static const Color bgColor = Color(0xFFFCE8E8);
  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color cardBg = Color(0xFFF9D9D9);
  static const Color activeBadgeBg = Color(0xFF5C1A1A);
  static const Color sideBarColor = Color(0xFF5C1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    _ProfileAvatar(),

                    const SizedBox(height: 14),

                    const Text(
                      'Ashraf Muhsin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Gold Member',
                      style: TextStyle(
                        fontSize: 14,
                        color: darkBrown,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _MenuItem(
                      icon: Icons.person,
                      label: 'Profile',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.local_shipping_rounded,
                      label: 'My Orders',
                      badge: '2 ACTIVE',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.favorite,
                      label: 'Wishlist',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.book_outlined,
                      label: 'Perfume Legendary  guide',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.settings,
                      label: 'App Settings',
                      onTap: () {},
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: 22,
            color: sideBarColor,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE8A020),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A020).withOpacity(0.45),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/Profile_photo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9D9D9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5C1A1A), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C1A1A),
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}