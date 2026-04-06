import 'package:flutter/material.dart';

class SearchResultScreen extends StatelessWidget {
  final String category;
  const SearchResultScreen({super.key, this.category = 'Oud'});

  static const Color bgColor   = Color(0xFFFCE8E8);
  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color goldColor = Color(0xFFCC8833);

  static const List<Map<String, dynamic>> _products = [
    {
      'name':  'Imperial Oud Noir',
      'price': '\$345',
      'image': 'assets/images/perfume1.jpg',
    },
    {
      'name':  'Rose Oud Elixir',
      'price': '\$615',
      'image': 'assets/images/perfume2.jpg',
    },
    {
      'name':  'Oud Mystique',
      'price': '\$420',
      'image': 'assets/images/perfume3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductCard(
                    name:  product['name']  as String,
                    price: product['price'] as String,
                    image: product['image'] as String,
                  );
                },
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left, color: darkBrown, size: 30),
          ),
          Expanded(
            child: Center(
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.filter_list_rounded, color: darkBrown, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: darkBrown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded,         label: 'Home',     active: false),
            _NavItem(icon: Icons.explore_rounded,      label: 'Explore',  active: true),
            _NavItem(icon: Icons.shopping_cart_rounded,label: 'Cart',     active: false),
            _NavItem(icon: Icons.person_rounded,       label: 'Profile',  active: false),
          ],
        ),
      ),
    );
  }
}
class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.image,
  });

  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color goldColor = Color(0xFFCC8833);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  image,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8CECE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        color: Color(0xFF5C1A1A), size: 48),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: goldColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: goldColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: darkBrown,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color goldColor = Color(0xFFCC8833);

  @override
  Widget build(BuildContext context) {
    final color = active ? goldColor : darkBrown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}