import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/buyer/profile_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/buyer_homescreen_widgets.dart';
import 'package:online_perfume_app_fyp/views/buyer/wishlist_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/product_listing.dart';

class BuyerHomescreen extends StatefulWidget {
  const BuyerHomescreen({super.key});

  @override
  State<BuyerHomescreen> createState() => _BuyerHomescreenState();
}

class _BuyerHomescreenState extends State<BuyerHomescreen> {
  // Dummy product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      "name": "Luxury Perfume",
      "brand": "Floral",
      "price": "\$120.00",
      "image": "assets/images/perfume.png",
      "rating": "4.8"
    },
    {
      "name": "Ocean Breeze",
      "brand": "Fresh",
      "price": "\$85.00",
      "image": "assets/images/perfume-6.png",
      "rating": "4.5"
    },
    {
      "name": "Midnight Rose",
      "brand": "Azan",
      "price": "\$95.00",
      "image": "assets/images/perfume.png", // Reusing image for dummy data
      "rating": "4.9"
    },
    {
      "name": "Citrus Splash",
      "brand": "Fresh",
      "price": "\$70.00",
      "image": "assets/images/perfume-6.png",
      "rating": "4.2"
    }
  ];

  String _selectedBrand = "All"; // 'All', 'Floral', 'Fresh', 'Azan'

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedBrand == "All") return _allProducts;
    return _allProducts.where((p) => p["brand"] == _selectedBrand).toList();
  }

  void _onBrandSelected(String brand) {
    setState(() {
      _selectedBrand = brand;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Buyer Home",
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      // menu-bar

      //drawer: customeDrawer(),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. Search Bar
            const HomeSearchBar(),
            const SizedBox(height: 20),

            // 2. Limited Offer Image
            const HomeLimitedOffer(),
            const SizedBox(height: 20),

            // 3. Featured Scent & Brands
            Text(
              "Featured Scent",
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BrandChip(
                    label: "All",
                    isSelected: _selectedBrand == "All",
                    onTap: () => _onBrandSelected("All"),
                  ),
                  const SizedBox(width: 10),
                  BrandChip(
                    label: "Floral",
                    imagePath: "assets/images/perfume.png",
                    isSelected: _selectedBrand == "Floral",
                    onTap: () => _onBrandSelected("Floral"),
                  ),
                  const SizedBox(width: 10),
                  BrandChip(
                    label: "Fresh",
                    imagePath: "assets/images/perfume-6.png",
                    isSelected: _selectedBrand == "Fresh",
                    onTap: () => _onBrandSelected("Fresh"),
                  ),
                  const SizedBox(width: 10),
                  BrandChip(
                    label: "Azan",
                    imagePath: "assets/images/perfume.png",
                    isSelected: _selectedBrand == "Azan",
                    onTap: () => _onBrandSelected("Azan"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Shop Now button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductListing()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A), // Brown/orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                child: Text(
                  "Shop Now",
                  style: GoogleFonts.poppins(
                      color: const Color(0xff5E1D04),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Gift Finder Section
            const HomeGiftFinder(),
            const SizedBox(height: 25),

            // Re-added Products GridView (Mix of products)
            Text(
              "Top Products",
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75, // Adjust based on card height
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductHomeCard(product: product);
              },
            ),

            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
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
